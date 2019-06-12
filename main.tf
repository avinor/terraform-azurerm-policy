terraform {
  backend "azurerm" {}
  required_version = ">= 0.12.0"
  required_providers {
    azurerm = ">= 1.29.0"
  }
}

