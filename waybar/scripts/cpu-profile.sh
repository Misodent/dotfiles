#!/bin/bash

cpu_usage=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}' || echo 'null')

text="[ БАЛАНС: ${cpu_usage}% ]"

echo "$text"
