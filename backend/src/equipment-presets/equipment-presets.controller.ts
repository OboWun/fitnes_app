import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  UsePipes,
  ValidationPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User } from '../entities/index.js';
import { EquipmentPresetsService } from './equipment-presets.service.js';
import { CreateEquipmentPresetDto } from './dto/create-equipment-preset.dto.js';
import { UpdateEquipmentPresetDto } from './dto/update-equipment-preset.dto.js';
import { CloneEquipmentPresetDto } from './dto/clone-equipment-preset.dto.js';
import { EquipmentPresetResponseDto } from './dto/equipment-preset-response.dto.js';

@ApiTags('Equipment Presets')
@Controller('equipment-presets')
export class EquipmentPresetsController {
  constructor(private readonly presetsService: EquipmentPresetsService) {}

  @Get('system')
  @ApiOperation({ summary: 'Get all system equipment presets' })
  @ApiQuery({
    name: 'includeDetails',
    required: false,
    type: Boolean,
    description: 'Include equipment name details',
  })
  @ApiOkResponse({ type: [EquipmentPresetResponseDto] })
  async getSystemPresets(
    @Query('includeDetails') includeDetails?: string,
  ): Promise<EquipmentPresetResponseDto[]> {
    const enrich = includeDetails === 'true';
    const presets = await this.presetsService.getSystemPresets(enrich);
    return presets.map((p) => ({
      id: p.id,
      userId: p.userId,
      name: p.name,
      slug: p.slug,
      isSystem: p.isSystem,
      equipmentSlugs: p.equipmentSlugs,
      equipmentDetails: (
        p as { equipmentDetails?: { slug: string; name: string }[] }
      ).equipmentDetails,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    }));
  }

  @Get()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get all user equipment presets' })
  @ApiQuery({
    name: 'includeDetails',
    required: false,
    type: Boolean,
    description: 'Include equipment name details',
  })
  @ApiOkResponse({ type: [EquipmentPresetResponseDto] })
  async getUserPresets(
    @CurrentUser() user: User,
    @Query('includeDetails') includeDetails?: string,
  ): Promise<EquipmentPresetResponseDto[]> {
    const enrich = includeDetails === 'true';
    const presets = await this.presetsService.getUserPresets(user.id, enrich);
    return presets.map((p) => ({
      id: p.id,
      userId: p.userId,
      name: p.name,
      slug: p.slug,
      isSystem: p.isSystem,
      equipmentSlugs: p.equipmentSlugs,
      equipmentDetails: (
        p as { equipmentDetails?: { slug: string; name: string }[] }
      ).equipmentDetails,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    }));
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Create a new equipment preset' })
  @ApiCreatedResponse({ type: EquipmentPresetResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateEquipmentPresetDto,
  ): Promise<EquipmentPresetResponseDto> {
    const preset = await this.presetsService.createPreset(user.id, dto);
    return {
      id: preset.id,
      userId: preset.userId,
      name: preset.name,
      slug: preset.slug,
      isSystem: preset.isSystem,
      equipmentSlugs: preset.equipmentSlugs,
      createdAt: preset.createdAt,
      updatedAt: preset.updatedAt,
    };
  }

  @Patch(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Update an equipment preset' })
  @ApiParam({ name: 'id', description: 'Preset ID' })
  @ApiOkResponse({ type: EquipmentPresetResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: UpdateEquipmentPresetDto,
  ): Promise<EquipmentPresetResponseDto> {
    const preset = await this.presetsService.updatePreset(user.id, id, dto);
    return {
      id: preset.id,
      userId: preset.userId,
      name: preset.name,
      slug: preset.slug,
      isSystem: preset.isSystem,
      equipmentSlugs: preset.equipmentSlugs,
      createdAt: preset.createdAt,
      updatedAt: preset.updatedAt,
    };
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Delete an equipment preset' })
  @ApiParam({ name: 'id', description: 'Preset ID' })
  @ApiNoContentResponse({ description: 'Preset deleted' })
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<void> {
    await this.presetsService.deletePreset(user.id, id);
  }

  @Post('clone/:sourceId')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Clone a system or user preset' })
  @ApiParam({ name: 'sourceId', description: 'Source preset ID to clone' })
  @ApiCreatedResponse({ type: EquipmentPresetResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async clone(
    @CurrentUser() user: User,
    @Param('sourceId') sourceId: string,
    @Body() dto: CloneEquipmentPresetDto,
  ): Promise<EquipmentPresetResponseDto> {
    const preset = await this.presetsService.clonePreset(user.id, sourceId, {
      name: dto.name,
      slug: dto.slug,
    });
    return {
      id: preset.id,
      userId: preset.userId,
      name: preset.name,
      slug: preset.slug,
      isSystem: preset.isSystem,
      equipmentSlugs: preset.equipmentSlugs,
      createdAt: preset.createdAt,
      updatedAt: preset.updatedAt,
    };
  }
}
