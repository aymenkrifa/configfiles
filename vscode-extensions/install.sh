#!/bin/bash

while IFS= read -r extension; do
    code --install-extension "$extension"
done < extensions