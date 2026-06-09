import { IsNotEmpty, IsNumber, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class RoutePointDto {
  @IsNumber()
  lat: number;

  @IsNumber()
  lng: number;

  @IsNumber()
  time: number;
}

export class CreateActivityDto {
  @IsNumber()
  distance: number;

  @IsNumber()
  duration: number;

  @IsString()
  @IsNotEmpty()
  startTime: string;

  @IsOptional()
  @IsString()
  endTime?: string;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => RoutePointDto)
  route?: RoutePointDto[];
}
