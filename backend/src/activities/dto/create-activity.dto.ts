import { IsNotEmpty, IsNumber, IsOptional, IsString, Min, ValidateNested } from 'class-validator';
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
  @Min(0)
  distance: number;

  @IsNumber()
  @Min(1)
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
