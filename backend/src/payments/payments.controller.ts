import { Body, Controller, Get, Headers, HttpCode, Param, Post, Req, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PaymentsService } from './payments.service';
import { CreatePaymentDto } from './dto/create-payment.dto';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req: any, @Body() dto: CreatePaymentDto) {
    return this.paymentsService.create(req.user.id, dto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getPayments(@Req() req: any) {
    return this.paymentsService.findByUser(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id/status')
  getStatus(@Req() req: any, @Param('id') id: string) {
    return this.paymentsService.getStatus(req.user.id, id);
  }

  @SkipThrottle()
  @Post('payme/webhook')
  @HttpCode(200)
  paymeWebhook(@Body() body: any, @Headers('authorization') authHeader: string) {
    return this.paymentsService.handlePaymeWebhook(body, authHeader);
  }

  @SkipThrottle()
  @Post('click/prepare')
  @HttpCode(200)
  clickPrepare(@Body() body: any) {
    return this.paymentsService.handleClickPrepare(body);
  }

  @SkipThrottle()
  @Post('click/complete')
  @HttpCode(200)
  clickComplete(@Body() body: any) {
    return this.paymentsService.handleClickComplete(body);
  }
}
