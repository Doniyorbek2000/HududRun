import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreatePaymentDto } from './dto/create-payment.dto';

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreatePaymentDto) {
    return this.prisma.payment.create({
      data: {
        userId,
        amount: dto.amount,
        status: dto.status,
      },
    });
  }

  async findByUser(userId: string) {
    return this.prisma.payment.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
