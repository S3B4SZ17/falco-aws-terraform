# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2023 The Falco Authors.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#-------------------------------------
# general resources
#-------------------------------------
module "resource_group" {
  source = "../../modules/infrastructure/resource-group"
  name   = var.name
  tags   = var.tags
}

# -------------------------------------
# ECS cluster
# -------------------------------------


module "vpc" {
  source = "../../modules/infrastructure/vpc"
  name   = var.name
  tags   = var.tags
}

module "ecs_cluster" {
  source           = "../../modules/infrastructure/ecs"
  ecs_cluster_name = var.name
  public_subnets   = module.vpc.public_subnets_ids
  private_subnets  = module.vpc.private_subnets_ids
  vpc_id           = module.vpc.vpc_id
  cidr             = module.vpc.cidr_block
}
