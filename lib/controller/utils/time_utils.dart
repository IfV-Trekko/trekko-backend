extension InclusiveRange on DateTime {
  bool isInInclusive(DateTime lowerBound, DateTime upperBound) {
    Duration difLow = this.difference(lowerBound);
    Duration difHi = upperBound.difference(this);
    return difLow.inMicroseconds >= 0 && difHi.inMicroseconds >= 0;
  }
}
