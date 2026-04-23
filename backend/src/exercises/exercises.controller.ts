import { Controller, Get, Param, Query, UsePipes, ValidationPipe } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';
import { ExercisesService } from './exercises.service.js';
import { ExerciseFilterQueryDto } from './dto/exercise-filter-query.dto.js';
import { PaginatedExercisesResponseDto } from './dto/paginated-exercises-response.dto.js';
import { PaginationQueryDto } from '../common/dto/index.js';

@ApiTags('Exercises')
@Controller('exercises')
export class ExercisesController {
  constructor(private readonly exercisesService: ExercisesService) {}

  @Get()
  @ApiOperation({ summary: 'Get exercises with pagination and filters' })
  @ApiOkResponse({ type: PaginatedExercisesResponseDto, description: 'Paginated list of exercises' })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  findAll(@Query() query: ExerciseFilterQueryDto): PaginatedExercisesResponseDto {
    const { page = 1, limit = 20, contraindications, equipments, targetMuscles, search } = query;
    return this.exercisesService.findAll(page, limit, {
      contraindications,
      equipments,
      targetMuscles,
      search,
    });
  }

  @Get(':slug/similar')
  @ApiOperation({ summary: 'Get similar exercises (same target muscle)' })
  @ApiParam({ name: 'slug', description: 'Exercise slug', example: 'band-shrug' })
  @ApiOkResponse({ type: PaginatedExercisesResponseDto, description: 'Paginated list of similar exercises' })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  findSimilar(
    @Param('slug') slug: string,
    @Query() query: PaginationQueryDto,
  ): PaginatedExercisesResponseDto {
    const { page = 1, limit = 20 } = query;
    return this.exercisesService.findSimilar(slug, page, limit);
  }

  @Get(':slug/antagonist')
  @ApiOperation({ summary: 'Get exercises for antagonist muscles' })
  @ApiParam({ name: 'slug', description: 'Exercise slug', example: 'band-shrug' })
  @ApiOkResponse({ type: PaginatedExercisesResponseDto, description: 'Paginated list of antagonist exercises' })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  findAntagonist(
    @Param('slug') slug: string,
    @Query() query: PaginationQueryDto,
  ): PaginatedExercisesResponseDto {
    const { page = 1, limit = 20 } = query;
    return this.exercisesService.findAntagonist(slug, page, limit);
  }
}
