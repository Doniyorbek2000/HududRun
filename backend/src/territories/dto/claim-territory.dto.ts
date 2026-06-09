import { IsNotEmpty, IsString } from 'class-validator';

export class ClaimTerritoryDto {
  @IsString()
  @IsNotEmpty()
  h3Index: string;
}
