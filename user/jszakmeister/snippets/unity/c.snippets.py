#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re

sys.path.append(
        os.path.join(os.path.dirname(__file__),
                     '..', '..', '..', '..', 'UltiSnips'))

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


#-------------------------------------------------------
# Basic Fail and Ignore
#-------------------------------------------------------

bsnip("utfm", "TEST_FAIL_MESSAGE(message)", r"""
TEST_FAIL_MESSAGE(${1:message});
""")

bsnip("utf", "TEST_FAIL()", r"""
TEST_FAIL(${1:});
""")

bsnip("utim", "TEST_IGNORE_MESSAGE(message)", r"""
TEST_IGNORE_MESSAGE(${1:message});
""")

bsnip("uti", "TEST_IGNORE()", r"""
TEST_IGNORE(${1:});
""")

bsnip("uto", "TEST_ONLY()", r"""
TEST_ONLY();
""")


#-------------------------------------------------------
# Test Asserts (simple)
#-------------------------------------------------------

# Boolean

bsnip("uta", "TEST_ASSERT(condition)", r"""
TEST_ASSERT(${1:condition});
""")

bsnip("utat", "TEST_ASSERT_TRUE(condition)", r"""
TEST_ASSERT_TRUE(${1:condition});
""")

bsnip("utau", "TEST_ASSERT_UNLESS(condition)", r"""
TEST_ASSERT_UNLESS(${1:condition});
""")

bsnip("utaf", "TEST_ASSERT_FALSE(condition)", r"""
TEST_ASSERT_FALSE(${1:condition});
""")

bsnip("utan", "TEST_ASSERT_NULL(pointer)", r"""
TEST_ASSERT_NULL(${1:pointer});
""")

bsnip("utann", "TEST_ASSERT_NOT_NULL(pointer)", r"""
TEST_ASSERT_NOT_NULL(${1:pointer});
""")


# Integers (of all sizes)

bsnip("utaei", "TEST_ASSERT_EQUAL_INT(expected, actual)", r"""
TEST_ASSERT_EQUAL_INT(${1:expected}, ${2:actual});
""")

bsnip("utaei8", "TEST_ASSERT_EQUAL_INT8(expected, actual)", r"""
TEST_ASSERT_EQUAL_INT8(${1:expected}, ${2:actual});
""")

bsnip("utaei16", "TEST_ASSERT_EQUAL_INT16(expected, actual)", r"""
TEST_ASSERT_EQUAL_INT16(${1:expected}, ${2:actual});
""")

bsnip("utaei32", "TEST_ASSERT_EQUAL_INT32(expected, actual)", r"""
TEST_ASSERT_EQUAL_INT32(${1:expected}, ${2:actual});
""")

bsnip("utaei64", "TEST_ASSERT_EQUAL_INT64(expected, actual)", r"""
TEST_ASSERT_EQUAL_INT64(${1:expected}, ${2:actual});
""")

bsnip("utae", "TEST_ASSERT_EQUAL(expected, actual)", r"""
TEST_ASSERT_EQUAL(${1:expected}, ${2:actual});
""")

bsnip("utane", "TEST_ASSERT_NOT_EQUAL(expected, actual)", r"""
TEST_ASSERT_NOT_EQUAL(${1:expected}, ${2:actual});
""")

bsnip("utaeu", "TEST_ASSERT_EQUAL_UINT(expected, actual)", r"""
TEST_ASSERT_EQUAL_UINT(${1:expected}, ${2:actual});
""")

bsnip("utaeu8", "TEST_ASSERT_EQUAL_UINT8(expected, actual)", r"""
TEST_ASSERT_EQUAL_UINT8(${1:expected}, ${2:actual});
""")

bsnip("utaeu16", "TEST_ASSERT_EQUAL_UINT16(expected, actual)", r"""
TEST_ASSERT_EQUAL_UINT16(${1:expected}, ${2:actual});
""")

bsnip("utaeu32", "TEST_ASSERT_EQUAL_UINT32(expected, actual)", r"""
TEST_ASSERT_EQUAL_UINT32(${1:expected}, ${2:actual});
""")

bsnip("utaeu64", "TEST_ASSERT_EQUAL_UINT64(expected, actual)", r"""
TEST_ASSERT_EQUAL_UINT64(${1:expected}, ${2:actual});
""")

bsnip("utaeh", "TEST_ASSERT_EQUAL_HEX(expected, actual)", r"""
TEST_ASSERT_EQUAL_HEX(${1:expected}, ${2:actual});
""")

bsnip("utaeh8", "TEST_ASSERT_EQUAL_HEX8(expected, actual)", r"""
TEST_ASSERT_EQUAL_HEX8(${1:expected}, ${2:actual});
""")

bsnip("utaeh16", "TEST_ASSERT_EQUAL_HEX16(expected, actual)", r"""
TEST_ASSERT_EQUAL_HEX16(${1:expected}, ${2:actual});
""")

bsnip("utaeh32", "TEST_ASSERT_EQUAL_HEX32(expected, actual)", r"""
TEST_ASSERT_EQUAL_HEX32(${1:expected}, ${2:actual});
""")

bsnip("utaeh64", "TEST_ASSERT_EQUAL_HEX64(expected, actual)", r"""
TEST_ASSERT_EQUAL_HEX64(${1:expected}, ${2:actual});
""")

bsnip("utab", "TEST_ASSERT_BITS(mask, expected, actual)", r"""
TEST_ASSERT_BITS(${1:mask}, ${2:expected}, ${3:actual});
""")

bsnip("utabh", "TEST_ASSERT_BITS_HIGH(mask, actual)", r"""
TEST_ASSERT_BITS_HIGH(${1:mask}, ${2:actual});
""")

bsnip("utabl", "TEST_ASSERT_BITS_LOW(mask, actual)", r"""
TEST_ASSERT_BITS_LOW(${1:mask}, ${2:actual});
""")

bsnip("utabh", "TEST_ASSERT_BIT_HIGH(bit, actual)", r"""
TEST_ASSERT_BIT_HIGH(${1:bit}, ${2:actual});
""")

bsnip("utabl", "TEST_ASSERT_BIT_LOW(bit, actual)", r"""
TEST_ASSERT_BIT_LOW(${1:bit}, ${2:actual});
""")


# Integer Ranges (of all sizes)

bsnip("utaiw", "TEST_ASSERT_INT_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_INT_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utauw", "TEST_ASSERT_UINT_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_UINT_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utahw", "TEST_ASSERT_HEX_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_HEX_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utah8w", "TEST_ASSERT_HEX8_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_HEX8_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utah16w", "TEST_ASSERT_HEX16_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_HEX16_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utah32w", "TEST_ASSERT_HEX32_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_HEX32_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utah64w", "TEST_ASSERT_HEX64_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_HEX64_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")


# Structs and Strings

bsnip("utaep", "TEST_ASSERT_EQUAL_PTR(expected, actual)", r"""
TEST_ASSERT_EQUAL_PTR(${1:expected}, ${2:actual});
""")

bsnip("utaes", "TEST_ASSERT_EQUAL_STRING(expected, actual)", r"""
TEST_ASSERT_EQUAL_STRING(${1:expected}, ${2:actual});
""")

bsnip("utaem", "TEST_ASSERT_EQUAL_MEMORY(expected, actual, len)", r"""
TEST_ASSERT_EQUAL_MEMORY(${1:expected}, ${2:actual}, ${3:len});
""")


# Arrays

bsnip("utaeia", "TEST_ASSERT_EQUAL_INT_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_INT_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaei8a", "TEST_ASSERT_EQUAL_INT8_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_INT8_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaei16a", "TEST_ASSERT_EQUAL_INT16_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_INT16_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaei32a", "TEST_ASSERT_EQUAL_INT32_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_INT32_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaei64a", "TEST_ASSERT_EQUAL_INT64_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_INT64_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeua", "TEST_ASSERT_EQUAL_UINT_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_UINT_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeu8a", "TEST_ASSERT_EQUAL_UINT8_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_UINT8_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeu16a", "TEST_ASSERT_EQUAL_UINT16_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_UINT16_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeu32a", "TEST_ASSERT_EQUAL_UINT32_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_UINT32_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeu64a", "TEST_ASSERT_EQUAL_UINT64_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_UINT64_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeha", "TEST_ASSERT_EQUAL_HEX_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_HEX_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeh8a", "TEST_ASSERT_EQUAL_HEX8_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_HEX8_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeh16a", "TEST_ASSERT_EQUAL_HEX16_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_HEX16_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeh32a", "TEST_ASSERT_EQUAL_HEX32_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_HEX32_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaeh64a", "TEST_ASSERT_EQUAL_HEX64_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_HEX64_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaepa", "TEST_ASSERT_EQUAL_PTR_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_PTR_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaesa", "TEST_ASSERT_EQUAL_STRING_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_STRING_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utaema", "TEST_ASSERT_EQUAL_MEMORY_ARRAY(expected, actual, len, num_elements)", r"""
TEST_ASSERT_EQUAL_MEMORY_ARRAY(${1:expected}, ${2:actual}, ${3:len}, ${4:num_elements});
""")


# Floating Point (If Enabled)

bsnip("utafw", "TEST_ASSERT_FLOAT_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_FLOAT_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utaef", "TEST_ASSERT_EQUAL_FLOAT(expected, actual)", r"""
TEST_ASSERT_EQUAL_FLOAT(${1:expected}, ${2:actual});
""")

bsnip("utaefa", "TEST_ASSERT_EQUAL_FLOAT_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_FLOAT_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utafii", "TEST_ASSERT_FLOAT_IS_INF(actual)", r"""
TEST_ASSERT_FLOAT_IS_INF(${1:actual});
""")

bsnip("utafini", "TEST_ASSERT_FLOAT_IS_NEG_INF(actual)", r"""
TEST_ASSERT_FLOAT_IS_NEG_INF(${1:actual});
""")

bsnip("utafin", "TEST_ASSERT_FLOAT_IS_NAN(actual)", r"""
TEST_ASSERT_FLOAT_IS_NAN(${1:actual});
""")


# Double (If Enabled)

bsnip("utadw", "TEST_ASSERT_DOUBLE_WITHIN(delta, expected, actual)", r"""
TEST_ASSERT_DOUBLE_WITHIN(${1:delta}, ${2:expected}, ${3:actual});
""")

bsnip("utaed", "TEST_ASSERT_EQUAL_DOUBLE(expected, actual)", r"""
TEST_ASSERT_EQUAL_DOUBLE(${1:expected}, ${2:actual});
""")

bsnip("utaeda", "TEST_ASSERT_EQUAL_DOUBLE_ARRAY(expected, actual, num_elements)", r"""
TEST_ASSERT_EQUAL_DOUBLE_ARRAY(${1:expected}, ${2:actual}, ${3:num_elements});
""")

bsnip("utadii", "TEST_ASSERT_DOUBLE_IS_INF(actual)", r"""
TEST_ASSERT_DOUBLE_IS_INF(${1:actual});
""")

bsnip("utadini", "TEST_ASSERT_DOUBLE_IS_NEG_INF(actual)", r"""
TEST_ASSERT_DOUBLE_IS_NEG_INF(${1:actual});
""")

bsnip("utadin", "TEST_ASSERT_DOUBLE_IS_NAN(actual)", r"""
TEST_ASSERT_DOUBLE_IS_NAN(${1:actual});
""")


#-------------------------------------------------------
# Test Asserts (with additional messages)
#-------------------------------------------------------

# Boolean

bsnip("utam", "TEST_ASSERT_MESSAGE(condition, message)", r"""
TEST_ASSERT_MESSAGE(${1:condition}, ${2:message});
""")

bsnip("utatm", "TEST_ASSERT_TRUE_MESSAGE(condition, message)", r"""
TEST_ASSERT_TRUE_MESSAGE(${1:condition}, ${2:message});
""")

bsnip("utaum", "TEST_ASSERT_UNLESS_MESSAGE(condition, message)", r"""
TEST_ASSERT_UNLESS_MESSAGE(${1:condition}, ${2:message});
""")

bsnip("utafm", "TEST_ASSERT_FALSE_MESSAGE(condition, message)", r"""
TEST_ASSERT_FALSE_MESSAGE(${1:condition}, ${2:message});
""")

bsnip("utanm", "TEST_ASSERT_NULL_MESSAGE(pointer, message)", r"""
TEST_ASSERT_NULL_MESSAGE(${1:pointer}, ${2:message});
""")

bsnip("utannm", "TEST_ASSERT_NOT_NULL_MESSAGE(pointer, message)", r"""
TEST_ASSERT_NOT_NULL_MESSAGE(${1:pointer}, ${2:message});
""")


# Integers (of all sizes)

bsnip("utaeim", "TEST_ASSERT_EQUAL_INT_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_INT_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaei8m", "TEST_ASSERT_EQUAL_INT8_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_INT8_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaei16m", "TEST_ASSERT_EQUAL_INT16_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_INT16_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaei32m", "TEST_ASSERT_EQUAL_INT32_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_INT32_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaei64m", "TEST_ASSERT_EQUAL_INT64_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_INT64_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaem", "TEST_ASSERT_EQUAL_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utanem", "TEST_ASSERT_NOT_EQUAL_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_NOT_EQUAL_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeum", "TEST_ASSERT_EQUAL_UINT_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_UINT_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeu8m", "TEST_ASSERT_EQUAL_UINT8_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_UINT8_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeu16m", "TEST_ASSERT_EQUAL_UINT16_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_UINT16_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeu32m", "TEST_ASSERT_EQUAL_UINT32_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_UINT32_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeu64m", "TEST_ASSERT_EQUAL_UINT64_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_UINT64_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaehm", "TEST_ASSERT_EQUAL_HEX_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_HEX_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeh8m", "TEST_ASSERT_EQUAL_HEX8_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_HEX8_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeh16m", "TEST_ASSERT_EQUAL_HEX16_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_HEX16_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeh32m", "TEST_ASSERT_EQUAL_HEX32_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_HEX32_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaeh64m", "TEST_ASSERT_EQUAL_HEX64_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_HEX64_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utabm", "TEST_ASSERT_BITS_MESSAGE(mask, expected, actual, message)", r"""
TEST_ASSERT_BITS_MESSAGE(${1:mask}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utabhm", "TEST_ASSERT_BITS_HIGH_MESSAGE(mask, actual, message)", r"""
TEST_ASSERT_BITS_HIGH_MESSAGE(${1:mask}, ${2:actual}, ${3:message});
""")

bsnip("utablm", "TEST_ASSERT_BITS_LOW_MESSAGE(mask, actual, message)", r"""
TEST_ASSERT_BITS_LOW_MESSAGE(${1:mask}, ${2:actual}, ${3:message});
""")

bsnip("utabhm", "TEST_ASSERT_BIT_HIGH_MESSAGE(bit, actual, message)", r"""
TEST_ASSERT_BIT_HIGH_MESSAGE(${1:bit}, ${2:actual}, ${3:message});
""")

bsnip("utablm", "TEST_ASSERT_BIT_LOW_MESSAGE(bit, actual, message)", r"""
TEST_ASSERT_BIT_LOW_MESSAGE(${1:bit}, ${2:actual}, ${3:message});
""")


# Integer Ranges (of all sizes)

bsnip("utaiwm", "TEST_ASSERT_INT_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_INT_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utauwm", "TEST_ASSERT_UINT_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_UINT_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utahwm", "TEST_ASSERT_HEX_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_HEX_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utah8wm", "TEST_ASSERT_HEX8_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_HEX8_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utah16wm", "TEST_ASSERT_HEX16_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_HEX16_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utah32wm", "TEST_ASSERT_HEX32_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_HEX32_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utah64wm", "TEST_ASSERT_HEX64_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_HEX64_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")


# Structs and Strings

bsnip("utaepm", "TEST_ASSERT_EQUAL_PTR_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_PTR_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaesm", "TEST_ASSERT_EQUAL_STRING_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_STRING_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaemm", "TEST_ASSERT_EQUAL_MEMORY_MESSAGE(expected, actual, len, message)", r"""
TEST_ASSERT_EQUAL_MEMORY_MESSAGE(${1:expected}, ${2:actual}, ${3:len}, ${4:message});
""")


# Arrays

bsnip("utaeiam", "TEST_ASSERT_EQUAL_INT_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_INT_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaei8am", "TEST_ASSERT_EQUAL_INT8_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_INT8_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaei16am", "TEST_ASSERT_EQUAL_INT16_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_INT16_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaei32am", "TEST_ASSERT_EQUAL_INT32_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_INT32_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaei64am", "TEST_ASSERT_EQUAL_INT64_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_INT64_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeuam", "TEST_ASSERT_EQUAL_UINT_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_UINT_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeu8am", "TEST_ASSERT_EQUAL_UINT8_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_UINT8_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeu16am", "TEST_ASSERT_EQUAL_UINT16_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_UINT16_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeu32am", "TEST_ASSERT_EQUAL_UINT32_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_UINT32_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeu64am", "TEST_ASSERT_EQUAL_UINT64_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_UINT64_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeham", "TEST_ASSERT_EQUAL_HEX_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_HEX_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeh8am", "TEST_ASSERT_EQUAL_HEX8_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_HEX8_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeh16am", "TEST_ASSERT_EQUAL_HEX16_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_HEX16_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeh32am", "TEST_ASSERT_EQUAL_HEX32_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_HEX32_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaeh64am", "TEST_ASSERT_EQUAL_HEX64_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_HEX64_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaepam", "TEST_ASSERT_EQUAL_PTR_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_PTR_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaesam", "TEST_ASSERT_EQUAL_STRING_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_STRING_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utaemam", "TEST_ASSERT_EQUAL_MEMORY_ARRAY_MESSAGE(expected, actual, len, num_elements, message)", r"""
TEST_ASSERT_EQUAL_MEMORY_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:len}, ${4:num_elements}, ${5:message});
""")


# Floating Point (If Enabled)

bsnip("utafwm", "TEST_ASSERT_FLOAT_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_FLOAT_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utaefm", "TEST_ASSERT_EQUAL_FLOAT_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_FLOAT_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaefam", "TEST_ASSERT_EQUAL_FLOAT_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_FLOAT_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utafiim", "TEST_ASSERT_FLOAT_IS_INF_MESSAGE(actual, message)", r"""
TEST_ASSERT_FLOAT_IS_INF_MESSAGE(${1:actual}, ${2:message});
""")

bsnip("utafinim", "TEST_ASSERT_FLOAT_IS_NEG_INF_MESSAGE(actual, message)", r"""
TEST_ASSERT_FLOAT_IS_NEG_INF_MESSAGE(${1:actual}, ${2:message});
""")

bsnip("utafinm", "TEST_ASSERT_FLOAT_IS_NAN_MESSAGE(actual, message)", r"""
TEST_ASSERT_FLOAT_IS_NAN_MESSAGE(${1:actual}, ${2:message});
""")


# Double (If Enabled)

bsnip("utadwm", "TEST_ASSERT_DOUBLE_WITHIN_MESSAGE(delta, expected, actual, message)", r"""
TEST_ASSERT_DOUBLE_WITHIN_MESSAGE(${1:delta}, ${2:expected}, ${3:actual}, ${4:message});
""")

bsnip("utaedm", "TEST_ASSERT_EQUAL_DOUBLE_MESSAGE(expected, actual, message)", r"""
TEST_ASSERT_EQUAL_DOUBLE_MESSAGE(${1:expected}, ${2:actual}, ${3:message});
""")

bsnip("utaedam", "TEST_ASSERT_EQUAL_DOUBLE_ARRAY_MESSAGE(expected, actual, num_elements, message)", r"""
TEST_ASSERT_EQUAL_DOUBLE_ARRAY_MESSAGE(${1:expected}, ${2:actual}, ${3:num_elements}, ${4:message});
""")

bsnip("utadiim", "TEST_ASSERT_DOUBLE_IS_INF_MESSAGE(actual, message)", r"""
TEST_ASSERT_DOUBLE_IS_INF_MESSAGE(${1:actual}, ${2:message});
""")

bsnip("utadinim", "TEST_ASSERT_DOUBLE_IS_NEG_INF_MESSAGE(actual, message)", r"""
TEST_ASSERT_DOUBLE_IS_NEG_INF_MESSAGE(${1:actual}, ${2:message});
""")

bsnip("utadinm", "TEST_ASSERT_DOUBLE_IS_NAN_MESSAGE(actual, message)", r"""
TEST_ASSERT_DOUBLE_IS_NAN_MESSAGE(${1:actual}, ${2:message});
""")
