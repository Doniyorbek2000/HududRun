import { IsNotEmpty, IsString, IsOptional, IsNumber, IsArray, Min } from 'class-validator';

export class ClaimTerritoryDto {
  @IsString()
  @IsNotEmpty()
  h3Index: string;

  @IsOptional()
  @IsArray()
  polygon?: Array<{ lat: number; lng: number }>;

  @IsOptional()
  @IsNumber()
  @Min(0)
  area?: number;
}
