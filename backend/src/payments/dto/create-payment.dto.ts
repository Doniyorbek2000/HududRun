import { IsIn, IsNotEmpty, IsString } from 'class-validator';

export const PAYMENT_PLANS = ['monthly', 'yearly'] as const;
export const PAYMENT_PROVIDERS = ['payme', 'click'] as const;

export class CreatePaymentDto {
  @IsString()
  @IsNotEmpty()
  @IsIn(PAYMENT_PLANS)
  plan: string;

  @IsString()
  @IsNotEmpty()
  @IsIn(PAYMENT_PROVIDERS)
  provider: string;
}
