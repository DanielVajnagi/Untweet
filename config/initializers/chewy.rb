Chewy.settings = {
  host: "localhost:9200",
  prefix: Rails.env,
  wait_for_status: "yellow",
  index: {
    number_of_shards: 1,
    number_of_replicas: 0
  }
}
