import {
  Controller,
  Get,
  Param,
  Query,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User } from '../entities/index.js';
import { ExercisesService } from './exercises.service.js';
import { ExerciseFilterQueryDto } from './dto/exercise-filter-query.dto.js';
import { PaginatedExercisesResponseDto } from './dto/paginated-exercises-response.dto.js';
import { ExerciseDetailResponseDto } from './dto/exercise-detail-response.dto.js';
import { PaginationQueryDto } from '../common/dto/index.js';

@ApiTags('Exercises')
@ApiBearerAuth()
@Controller('exercises')
@UseGuards(JwtAuthGuard)
export class ExercisesController {
  constructor(private readonly exercisesService: ExercisesService) {}

  @Get()
  @ApiOperation({ summary: 'Get exercises with pagination and filters' })
  @ApiOkResponse({
    type: PaginatedExercisesResponseDto,
    description: 'Paginated list of exercises',
  })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async findAll(
    @CurrentUser() user: User,
    @Query() query: ExerciseFilterQueryDto,
  ): Promise<PaginatedExercisesResponseDto> {
    const {
      page = 1,
      limit = 20,
      contraindications,
      equipments,
      targetMuscles,
      search,
      isPersonal,
    } = query;
    return this.exercisesService.findAll(
      page,
      limit,
      { contraindications, equipments, targetMuscles, search },
      user,
      isPersonal,
    );
  }

  @Get(':slug')
  @ApiOperation({ summary: 'Get exercise detail by slug' })
  @ApiParam({ name: 'slug', description: 'Exercise slug', example: 'band-shrug' })
  @ApiOkResponse({
    type: ExerciseDetailResponseDto,
    description: 'Exercise detail with user-specific contraindications',
  })
  async findOne(
    @CurrentUser() user: User,
    @Param('slug') slug: string,
  ): Promise<ExerciseDetailResponseDto> {
    return this.exercisesService.findOne(slug, user);
  }

  @Get(':slug/similar')
  @ApiOperation({ summary: 'Get similar exercises (same target muscle)' })
  @ApiParam({ name: 'slug', description: 'Exercise slug', example: 'band-shrug' })
  @ApiOkResponse({
    type: PaginatedExercisesResponseDto,
    description: 'Paginated list of similar exercises',
  })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async findSimilar(
    @CurrentUser() user: User,
    @Param('slug') slug: string,
    @Query() query: PaginationQueryDto,
  ): Promise<PaginatedExercisesResponseDto> {
    const { page = 1, limit = 20 } = query;
    return this.exercisesService.findSimilar(slug, page, limit, user);
  }

  @Get(':slug/antagonist')
  @ApiOperation({ summary: 'Get exercises for antagonist muscles' })
  @ApiParam({ name: 'slug', description: 'Exercise slug', example: 'band-shrug' })
  @ApiOkResponse({
    type: PaginatedExercisesResponseDto,
    description: 'Paginated list of antagonist exercises',
  })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async findAntagonist(
    @CurrentUser() user: User,
    @Param('slug') slug: string,
    @Query() query: PaginationQueryDto,
  ): Promise<PaginatedExercisesResponseDto> {
    const { page = 1, limit = 20 } = query;
    return this.exercisesService.findAntagonist(slug, page, limit, user);
  }
}
