import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class PaginatedResponseDto<T> {
  @ApiProperty({ description: 'Массив данных' })
  data: T[];

  @ApiProperty({ description: 'Общее количество записей' })
  total: number;

  @ApiProperty({ description: 'Текущее смещение' })
  offset: number;

  @ApiProperty({ description: 'Лимит записей на страницу' })
  limit: number;

  constructor(data: T[], total: number, offset: number, limit: number) {
    this.data = data;
    this.total = total;
    this.offset = offset;
    this.limit = limit;
  }

  static create<T>(data: T[], total: number, offset: number, limit: number): PaginatedResponseDto<T> {
    return new PaginatedResponseDto(data, total, offset, limit);
  }
}
