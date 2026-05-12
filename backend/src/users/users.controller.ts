import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User } from '../entities/index.js';
import { UsersService } from './users.service.js';
import { UpdateProfileDto } from './dto/update-profile.dto.js';
import { UserProfileResponseDto } from './dto/user-profile-response.dto.js';

@ApiTags('Users')
@ApiBearerAuth()
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiOkResponse({ type: UserProfileResponseDto, description: 'User profile' })
  getProfile(@CurrentUser() user: User): UserProfileResponseDto {
    return this.toResponseDto(user);
  }

  @Patch('profile')
  @ApiOperation({ summary: 'Update current user profile' })
  @ApiOkResponse({
    type: UserProfileResponseDto,
    description: 'Updated user profile',
  })
  async updateProfile(
    @CurrentUser() user: User,
    @Body() dto: UpdateProfileDto,
  ): Promise<UserProfileResponseDto> {
    const metadataUpdate: Record<string, unknown> = {};
    if (dto.goal !== undefined) metadataUpdate.goal = dto.goal;
    if (dto.experienceLevel !== undefined)
      metadataUpdate.experienceLevel = dto.experienceLevel;
    if (dto.availableEquipment !== undefined)
      metadataUpdate.availableEquipment = dto.availableEquipment;
    if (dto.defaultEquipmentPresetId !== undefined)
      metadataUpdate.defaultEquipmentPresetId = dto.defaultEquipmentPresetId;

    const updated = await this.usersService.update(user.id, {
      ...(dto.name !== undefined && { name: dto.name }),
      ...(dto.gender !== undefined && { gender: dto.gender }),
      ...(dto.weight !== undefined && { weight: dto.weight }),
      ...(dto.height !== undefined && { height: dto.height }),
      ...(dto.age !== undefined && { age: dto.age }),
      ...(dto.contraindications !== undefined && {
        contraindications: dto.contraindications,
      }),
      ...(Object.keys(metadataUpdate).length > 0 && {
        metadata: { ...(user.metadata ?? {}), ...metadataUpdate },
      }),
    });
    return this.toResponseDto(updated!);
  }

  private toResponseDto(user: User): UserProfileResponseDto {
    const meta = user.metadata;
    return {
      id: user.id,
      deviceId: user.deviceId,
      name: user.name,
      gender: user.gender,
      weight: user.weight,
      height: user.height,
      age: user.age,
      contraindications: user.contraindications ?? [],
      createdAt: user.createdAt,
      metadata: meta
        ? {
            goal: meta.goal ?? undefined,
            experienceLevel: meta.experienceLevel ?? undefined,
            availableEquipment: meta.availableEquipment ?? undefined,
            trainingAgeMonths: meta.trainingAgeMonths ?? undefined,
            recoveryCapacity: meta.recoveryCapacity ?? undefined,
            injuryHistory: meta.injuryHistory ?? undefined,
            currentLimitations: meta.currentLimitations ?? undefined,
            preferredExercises: meta.preferredExercises ?? undefined,
            dislikedExercises: meta.dislikedExercises ?? undefined,
            preferredMovementPatterns:
              meta.preferredMovementPatterns ?? undefined,
            defaultEquipmentPresetId:
              meta.defaultEquipmentPresetId ?? undefined,
          }
        : undefined,
    };
  }
}
