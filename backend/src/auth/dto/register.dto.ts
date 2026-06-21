import { IsNotEmpty, IsOptional, IsString, MaxLength, Matches, MinLength } from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(30)
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
