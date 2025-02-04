#!/bin/bash

# Get the comma-separated test suites from the input
IFS=',' read -ra SUITES <<< "$INPUT_TEST_SUITES"

# Loop through each test suite (A, B)
for suite in "${SUITES[@]}"; do
  echo "Starting container for suite: $suite"
  
  # Create a container for the test suite (A or B)
  docker run -d --rm --name "test-suite-${suite}" -v /var/run/docker.sock:/var/run/docker.sock docker:latest /bin/sh -c "echo 'Running $suite container'; /action/run_test.sh $suite"
  
  # Loop through and create 3 containers for each suite
  for i in $(seq 1 3); do
    echo "Creating container $i for suite $suite..."
    
    # Create a container inside the suite container that prints helloworld
    docker run -d --rm --name "test-${suite}-${i}" alpine:latest /bin/sh -c "echo 'helloworldfrom${suite}'"
  done

  # Wait for the inner test containers to complete
  docker wait $(docker ps -q --filter "name=test-${suite}-")
done

echo "All containers have completed."
