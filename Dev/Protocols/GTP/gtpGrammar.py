#
# Copyright (c) 2019, Infosys Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import os, sys
import openpyxl

gtp_grammar_file = os.path.join(os.path.dirname(__file__), 'gtpV2StackModel.xlsx')
# Using openpyxl modules to read from Excel workbook
workbook = openpyxl.load_workbook(gtp_grammar_file)


