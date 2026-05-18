import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User } from '../entities/index.js';
import { HomeDataService } from './home-data.service.js';
import { HomeDataQueryDto, HomeDataResponseDto } from './dto/home-data.dto.js';

@ApiTags('Home')
@ApiBearerAuth()
@Controller('home')
@UseGuards(JwtAuthGuard)
export class HomeController {
  constructor(private readonly homeDataService: HomeDataService) {}

  @Get('data')
  @ApiOperation({ summary: 'Get home page data' })
  @ApiOkResponse({ type: HomeDataResponseDto })
  async getHomeData(
    @CurrentUser() user: User,
    @Query() query: HomeDataQueryDto,
  ): Promise<HomeDataResponseDto> {
    return this.homeDataService.getHomeData(user.id, query.weekStart);
  }
}
