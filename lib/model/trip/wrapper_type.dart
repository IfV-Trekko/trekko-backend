enum WrapperType<T> {
  ANALYZER(true),
  MANUAL(false);

  final bool needsRealPositionData;

  const WrapperType(this.needsRealPositionData);
}
