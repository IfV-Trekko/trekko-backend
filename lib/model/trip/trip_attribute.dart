enum TripAttribute {

  // TODO: Use them in the table definition
  id("uid"),
  end_time("startTime"),
  start_time("endTime"),
  transport_type("transportType"),
  donation_status("donationStatus");

  final String name;

  const TripAttribute(this.name);
}