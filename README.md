# ExCluster

This project is only to experiment to get an Elixir cluster up and running. First locally, but also on AWS ECS. For Kubernetes there exists several descriptions out there. But for ECS (which can potentially be a better fit for smaller projects) there is virtually none.

## Locally

To get up and running on docker locally, run the following commands:

* `docker build -t ex_cluster:latest .`
* `docker-compose up`

To test, you should open a browser to one of the two adresses: [http://localhost:4001](http://localhost:4001) or [http://localhost:4002](http://localhost:4002) or [http://localhost:4003](http://localhost:4003). The result from any of those nodes should be something like this (name of self, and list of the other two nodes, if connected successfully):
`{"nodes":["node3@node3.local","node2@node2.local"],"self":"node1@node1.local"}`

## AWS

Next step is to get the same cluster running on AWS ECS using Fargate and service discovery.
