#!/bin/bash
set -e

# Source this so that nvm works
. ~/.nvm/nvm.sh

project_dir=$(pwd)

echo "Configuring backend application"
cd backend
echo "Cleaning backend environment..."
pipenv --rm > /dev/null 2>&1 || true
echo "Done with cleanup!"

echo "Installing backend dependencies..."
pipenv install > /dev/null 2>&1
echo "Done configuring backend!"
cd $project_dir

echo "Configuring frontend application"
cd frontend
echo "Cleaning frontend environment..."
npm run clean > /dev/null 2>&1

echo "Installing frontend dependencies..."
nvm install > /dev/null 2>&1
npm ci --silent > /dev/null 2>&1
echo "Done configuring frontend!"
cd $project_dir

echo "Done setting up workspace 🚀"