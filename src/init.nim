# Copyright 2017 Mamy André-Ratsimbazafy
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

proc newTensor*(shape: seq[int], T: typedesc, B: static[Backend]): Tensor[B,T] {.noSideEffect.} =
    ## Compute strides matching with dimensions.
    ## Row-Major ordering, rows have strides of 1
    # TODO support array/openarray. Pending https://github.com/nim-lang/Nim/issues/2652
    let strides = (shape & 1)[1..shape.len].scanr(a * b)

    result.dimensions = shape.reversed
    result.strides = strides
    result.data = newSeq[T](shape.product)
    result.offset = addr result.data[0]
    return result

proc fromSeq*[U](s: seq[U], T: typedesc, B: static[Backend]): Tensor[B,T] {.noSideEffect.} =
    ## Create a tensor from a nested sequence
    ## Unfortunately it can't typecheck without auto if T is another sequence
    let shape = s.shape
    let flat = s.flatten

    when compileOption("boundChecks"):
      if (shape.product != flat.len):
        raise newException(IndexError, "Each nested sequence at the same level must have the same number of elements")

    let strides = (shape & 1)[1..shape.len].scanr(a * b)

    result.dimensions = shape.reversed
    result.strides = strides
    result.data = flat
    result.offset = addr result.data[0]
    return result