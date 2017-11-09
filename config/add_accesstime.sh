#!/bin/bash

su postgres
psql -p 5433 -d changeset -c “ALTER TABLE final_reports ADD COLUMN accesstime integer"
