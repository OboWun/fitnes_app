import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsISO8601 } from 'class-validator';

export class HomeDataQueryDto {
  @ApiPropertyOptional({
    description: 'Дата начала недели (ISO 8601, YYYY-MM-DD)',
    example: '2026-05-18',
  })
  @IsOptional()
  @IsISO8601()
  weekStart?: string;
}

export class ActiveBlockDto {
  @ApiProperty() id: string;
  @ApiProperty() name: string;
  @ApiProperty() type: string;
  @ApiProperty() durationWeeks: number;
  @ApiPropertyOptional() goal?: string;
  @ApiPropertyOptional() splitName?: string;
  @ApiPropertyOptional() currentWeek?: number;
}

export class WeekSessionDto {
  @ApiProperty() id: string;
  @ApiProperty() dayOfWeek: string;
  @ApiProperty() date: string;
  @ApiProperty() status: string;
  @ApiPropertyOptional() sessionType?: string;
  @ApiPropertyOptional() description?: string;
  @ApiPropertyOptional() exerciseCount?: number;
  @ApiPropertyOptional() time?: string;
}

export class TodaySessionDto {
  @ApiProperty() id: string;
  @ApiPropertyOptional() sessionType?: string;
  @ApiPropertyOptional() description?: string;
  @ApiPropertyOptional() time?: string;
  @ApiPropertyOptional() exerciseCount?: number;
}

export class HomeDataResponseDto {
  @ApiPropertyOptional({ type: ActiveBlockDto })
  activeBlock: ActiveBlockDto | null;

  @ApiProperty({ type: [WeekSessionDto] })
  weekSessions: WeekSessionDto[];

  @ApiProperty() weekStart: string;
  @ApiProperty() weekEnd: string;

  @ApiPropertyOptional({ type: TodaySessionDto })
  todaySession: TodaySessionDto | null;
}
