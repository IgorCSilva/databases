function insertCity(
  name,
  population,
  lastCensus,
  famousFor,
  mayorInfo
) {
  db.towns.insertOne({
    name: name,
    population: population,
    lastCensus: ISODate(lastCensus),
    famousFor: famousFor,
    mayor: mayorInfo
  })
}