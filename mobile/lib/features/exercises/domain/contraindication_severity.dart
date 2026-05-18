enum ContraindicationSeverity {
  lowWeight,
  notRecommended,
  forbidden;

  static ContraindicationSeverity? fromString(String? value) {
    return switch (value) {
      'low_weight' => ContraindicationSeverity.lowWeight,
      'not_recommended' => ContraindicationSeverity.notRecommended,
      'forbidden' => ContraindicationSeverity.forbidden,
      _ => null,
    };
  }

  String get label => switch (this) {
        ContraindicationSeverity.lowWeight => 'Сниженный вес',
        ContraindicationSeverity.notRecommended => 'Не рекомендуется',
        ContraindicationSeverity.forbidden => 'Противопоказано',
      };
}
