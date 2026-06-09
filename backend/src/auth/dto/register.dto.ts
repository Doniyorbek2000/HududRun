import { IsNotEmpty, IsOptional, IsString, Matches } from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  username: string;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^(?=.{8,}).*$/, {
    message: 'Password must be at least 8 characters long',
  })
  password: string;
}
