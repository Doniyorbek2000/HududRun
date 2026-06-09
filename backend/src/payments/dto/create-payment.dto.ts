import { IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class CreatePaymentDto {
  @IsNumber()
  amount: number;

  @IsString()
  @IsNotEmpty()
  status: string;
}
