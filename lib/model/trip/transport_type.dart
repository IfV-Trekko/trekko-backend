// Leave order and names as is!
enum TransportType {
  by_foot("BY_FOOT"),
  bicycle("BICYCLE"),
  car("CAR"),
  publicTransport("PUBLIC_TRANSPORT"),
  ship("SHIP"),
  plane("PLANE"),
  other("OTHER");

  final String name;

  const TransportType(this.name);

  String toString() => name;
}
