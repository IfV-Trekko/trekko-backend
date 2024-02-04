class BuildException<T> {
  final T reason;
  final Exception? cause;

  BuildException(this.cause, this.reason);

  @override
  String toString() {
    return "RequestException: $reason, $cause";
  }
}
