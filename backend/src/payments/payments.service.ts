import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { PrismaService } from '../prisma.service';
import { CreatePaymentDto } from './dto/create-payment.dto';

export const PLAN_PRICES: Record<string, number> = {
  monthly: 29000,
  yearly: 249000,
};

// Payme transaction states (https://developer.help.paycom.uz/)
const PAYME_STATE_CREATED = 1;
const PAYME_STATE_COMPLETED = 2;
const PAYME_STATE_CANCELLED = -1;
const PAYME_STATE_CANCELLED_AFTER_COMPLETE = -2;

const PAYME_ERROR = {
  UNAUTHORIZED: -32504,
  INVALID_AMOUNT: -31001,
  ACCOUNT_NOT_FOUND: -31050,
  TRANSACTION_NOT_FOUND: -31003,
  UNABLE_TO_PERFORM: -31008,
  METHOD_NOT_FOUND: -32601,
};

@Injectable()
export class PaymentsService {
  constructor(
    private prisma: PrismaService,
    private config: ConfigService,
  ) {}

  async create(userId: string, dto: CreatePaymentDto) {
    const amount = PLAN_PRICES[dto.plan];
    if (!amount) throw new BadRequestException('Invalid plan');

    const payment = await this.prisma.payment.create({
      data: {
        userId,
        amount,
        plan: dto.plan,
        provider: dto.provider,
        status: 'pending',
      },
    });

    return { payment, checkoutUrl: this.buildCheckoutUrl(payment) };
  }

  async findByUser(userId: string) {
    return this.prisma.payment.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getStatus(userId: string, id: string) {
    const payment = await this.prisma.payment.findFirst({ where: { id, userId } });
    if (!payment) throw new NotFoundException('Payment not found');
    return payment;
  }

  private buildCheckoutUrl(payment: { id: string; amount: number; provider: string }): string {
    if (payment.provider === 'payme') {
      const merchantId = this.config.get<string>('PAYME_MERCHANT_ID') ?? '';
      const amountTiyin = Math.round(payment.amount * 100);
      const params = `m=${merchantId};ac.payment_id=${payment.id};a=${amountTiyin}`;
      return `https://checkout.paycom.uz/${Buffer.from(params).toString('base64')}`;
    }

    if (payment.provider === 'click') {
      const merchantId = this.config.get<string>('CLICK_MERCHANT_ID') ?? '';
      const serviceId = this.config.get<string>('CLICK_SERVICE_ID') ?? '';
      const returnUrl =
        this.config.get<string>('CLICK_RETURN_URL') ?? 'https://hududrun.app/payment/return';
      const params = new URLSearchParams({
        service_id: serviceId,
        merchant_id: merchantId,
        amount: payment.amount.toFixed(2),
        transaction_param: payment.id,
        return_url: returnUrl,
      });
      return `https://my.click.uz/services/pay?${params.toString()}`;
    }

    throw new BadRequestException('Unsupported provider');
  }

  // ───────────────────────────── Payme webhook ─────────────────────────────
  // JSON-RPC 2.0 Merchant API: https://developer.help.paycom.uz/

  async handlePaymeWebhook(body: any, authHeader?: string) {
    const id = body?.id ?? null;

    if (!this.verifyPaymeAuth(authHeader)) {
      return this.paymeError(id, PAYME_ERROR.UNAUTHORIZED, 'Insufficient privileges');
    }

    switch (body?.method) {
      case 'CheckPerformTransaction':
        return this.paymeCheckPerformTransaction(id, body.params);
      case 'CreateTransaction':
        return this.paymeCreateTransaction(id, body.params);
      case 'PerformTransaction':
        return this.paymePerformTransaction(id, body.params);
      case 'CancelTransaction':
        return this.paymeCancelTransaction(id, body.params);
      case 'CheckTransaction':
        return this.paymeCheckTransaction(id, body.params);
      default:
        return this.paymeError(id, PAYME_ERROR.METHOD_NOT_FOUND, 'Method not found');
    }
  }

  private verifyPaymeAuth(authHeader?: string): boolean {
    const merchantKey = this.config.get<string>('PAYME_MERCHANT_KEY');
    if (!merchantKey || !authHeader?.startsWith('Basic ')) return false;
    const decoded = Buffer.from(authHeader.slice('Basic '.length), 'base64').toString('utf-8');
    const key = decoded.slice(decoded.indexOf(':') + 1);
    return key === merchantKey;
  }

  private paymeError(id: any, code: number, message: string) {
    return { error: { code, message: { ru: message, uz: message, en: message } }, id };
  }

  private async paymeFindPayment(params: any) {
    const paymentId = params?.account?.payment_id;
    if (!paymentId) return null;
    return this.prisma.payment.findUnique({ where: { id: paymentId } });
  }

  private async paymeCheckPerformTransaction(id: any, params: any) {
    const payment = await this.paymeFindPayment(params);
    if (!payment || payment.provider !== 'payme') {
      return this.paymeError(id, PAYME_ERROR.ACCOUNT_NOT_FOUND, 'Payment not found');
    }
    if (payment.status !== 'pending') {
      return this.paymeError(id, PAYME_ERROR.ACCOUNT_NOT_FOUND, 'Payment already processed');
    }
    if (params?.amount !== Math.round(payment.amount * 100)) {
      return this.paymeError(id, PAYME_ERROR.INVALID_AMOUNT, 'Incorrect amount');
    }
    return { result: { allow: true }, id };
  }

  private async paymeCreateTransaction(id: any, params: any) {
    const payment = await this.paymeFindPayment(params);
    if (!payment || payment.provider !== 'payme') {
      return this.paymeError(id, PAYME_ERROR.ACCOUNT_NOT_FOUND, 'Payment not found');
    }
    if (params?.amount !== Math.round(payment.amount * 100)) {
      return this.paymeError(id, PAYME_ERROR.INVALID_AMOUNT, 'Incorrect amount');
    }

    if (payment.externalTransactionId) {
      if (payment.externalTransactionId !== params.id) {
        return this.paymeError(id, PAYME_ERROR.ACCOUNT_NOT_FOUND, 'Payment already has a transaction');
      }
      if (payment.status === 'cancelled' || payment.status === 'failed') {
        return this.paymeError(id, PAYME_ERROR.UNABLE_TO_PERFORM, 'Transaction cancelled');
      }
      return {
        result: {
          create_time: payment.createdAt.getTime(),
          transaction: payment.id,
          state: payment.status === 'completed' ? PAYME_STATE_COMPLETED : PAYME_STATE_CREATED,
        },
        id,
      };
    }

    if (payment.status !== 'pending') {
      return this.paymeError(id, PAYME_ERROR.UNABLE_TO_PERFORM, 'Payment already processed');
    }

    await this.prisma.payment.update({
      where: { id: payment.id },
      data: { externalTransactionId: params.id },
    });

    return {
      result: { create_time: Date.now(), transaction: payment.id, state: PAYME_STATE_CREATED },
      id,
    };
  }

  private async paymePerformTransaction(id: any, params: any) {
    const payment = await this.prisma.payment.findFirst({
      where: { externalTransactionId: params?.id, provider: 'payme' },
    });
    if (!payment) {
      return this.paymeError(id, PAYME_ERROR.TRANSACTION_NOT_FOUND, 'Transaction not found');
    }

    if (payment.status === 'completed') {
      return {
        result: {
          transaction: payment.id,
          perform_time: payment.updatedAt.getTime(),
          state: PAYME_STATE_COMPLETED,
        },
        id,
      };
    }

    if (payment.status !== 'pending') {
      return this.paymeError(id, PAYME_ERROR.UNABLE_TO_PERFORM, 'Unable to perform operation');
    }

    await this.prisma.$transaction([
      this.prisma.payment.update({ where: { id: payment.id }, data: { status: 'completed' } }),
      this.prisma.user.update({ where: { id: payment.userId }, data: { isPremium: true } }),
    ]);

    return {
      result: { transaction: payment.id, perform_time: Date.now(), state: PAYME_STATE_COMPLETED },
      id,
    };
  }

  private async paymeCancelTransaction(id: any, params: any) {
    const payment = await this.prisma.payment.findFirst({
      where: { externalTransactionId: params?.id, provider: 'payme' },
    });
    if (!payment) {
      return this.paymeError(id, PAYME_ERROR.TRANSACTION_NOT_FOUND, 'Transaction not found');
    }

    const wasCompleted = payment.status === 'completed';
    if (payment.status !== 'cancelled' && payment.status !== 'failed') {
      await this.prisma.payment.update({ where: { id: payment.id }, data: { status: 'cancelled' } });
    }

    return {
      result: {
        transaction: payment.id,
        cancel_time: Date.now(),
        state: wasCompleted ? PAYME_STATE_CANCELLED_AFTER_COMPLETE : PAYME_STATE_CANCELLED,
      },
      id,
    };
  }

  private async paymeCheckTransaction(id: any, params: any) {
    const payment = await this.prisma.payment.findFirst({
      where: { externalTransactionId: params?.id, provider: 'payme' },
    });
    if (!payment) {
      return this.paymeError(id, PAYME_ERROR.TRANSACTION_NOT_FOUND, 'Transaction not found');
    }

    let state = PAYME_STATE_CREATED;
    if (payment.status === 'completed') state = PAYME_STATE_COMPLETED;
    else if (payment.status === 'cancelled' || payment.status === 'failed') state = PAYME_STATE_CANCELLED;

    return {
      result: {
        create_time: payment.createdAt.getTime(),
        perform_time: payment.status === 'completed' ? payment.updatedAt.getTime() : 0,
        cancel_time: state < 0 ? payment.updatedAt.getTime() : 0,
        transaction: payment.id,
        state,
        reason: null,
      },
      id,
    };
  }

  // ───────────────────────────── Click webhook ─────────────────────────────
  // Prepare/Complete actions: https://docs.click.uz/

  async handleClickPrepare(body: any) {
    return this.handleClickAction(body, 0);
  }

  async handleClickComplete(body: any) {
    return this.handleClickAction(body, 1);
  }

  private async handleClickAction(body: any, action: 0 | 1) {
    const {
      click_trans_id,
      service_id,
      merchant_trans_id,
      merchant_prepare_id,
      amount,
      sign_time,
      sign_string,
      error,
    } = body ?? {};

    const secretKey = this.config.get<string>('CLICK_SECRET_KEY');
    if (!secretKey) {
      return this.clickResponse(body, -1, 'SIGN CHECK FAILED');
    }

    const signSource =
      action === 0
        ? `${click_trans_id}${service_id}${secretKey}${merchant_trans_id}${amount}${action}${sign_time}`
        : `${click_trans_id}${service_id}${secretKey}${merchant_trans_id}${merchant_prepare_id}${amount}${action}${sign_time}`;
    const expectedSign = crypto.createHash('md5').update(signSource).digest('hex');

    if (expectedSign !== sign_string) {
      return this.clickResponse(body, -1, 'SIGN CHECK FAILED');
    }

    const payment = await this.prisma.payment.findUnique({ where: { id: merchant_trans_id } });
    if (!payment || payment.provider !== 'click') {
      return this.clickResponse(body, -5, 'User does not exist');
    }

    if (Math.abs(payment.amount - Number(amount)) > 0.01) {
      return this.clickResponse(body, -2, 'Incorrect parameter amount');
    }

    if (action === 0) {
      if (payment.status === 'completed') {
        return this.clickResponse(body, -4, 'Already paid');
      }
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: { externalTransactionId: String(click_trans_id) },
      });
      return this.clickResponse(body, 0, 'Success', { merchant_prepare_id: payment.id });
    }

    // Complete (action === 1)
    if (Number(error) < 0) {
      await this.prisma.payment.update({ where: { id: payment.id }, data: { status: 'failed' } });
      return this.clickResponse(body, 0, 'Success', { merchant_confirm_id: payment.id });
    }

    if (payment.status !== 'completed') {
      await this.prisma.$transaction([
        this.prisma.payment.update({ where: { id: payment.id }, data: { status: 'completed' } }),
        this.prisma.user.update({ where: { id: payment.userId }, data: { isPremium: true } }),
      ]);
    }

    return this.clickResponse(body, 0, 'Success', { merchant_confirm_id: payment.id });
  }

  private clickResponse(body: any, errorCode: number, errorNote: string, extra: Record<string, any> = {}) {
    return {
      click_trans_id: body?.click_trans_id,
      merchant_trans_id: body?.merchant_trans_id,
      error: errorCode,
      error_note: errorNote,
      ...extra,
    };
  }
}
