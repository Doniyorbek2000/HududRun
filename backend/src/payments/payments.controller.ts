import { Controller, Get, Post, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PaymentsService } from './payments.service';
import { CreatePaymentDto } from './dto/create-payment.dto';

@Controller('payments')
@UseGuards(JwtAuthGuard)
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post()
  createPayment(@Req() req: any, @Body() dto: CreatePaymentDto) {
    return this.paymentsService.create(req.user.id, dto);
  }

  @Get('me')
  getPayments(@Req() req: any) {
    return this.paymentsService.findByUser(req.user.id);
  }
}
