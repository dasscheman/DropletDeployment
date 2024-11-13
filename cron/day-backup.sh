#!/bin/bash

for dir in ../www/*/; do
  php $dir/artisan schedule:run
done