// cpsm - fuzzy path matcher
// Copyright (C) 2015 Jamie Liu
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <algorithm>
#include <cinttypes>
#include <cstdio>
#include <stdexcept>
#include <string>
#include <vector>

#include "api.h"
#include "str_util.h"

namespace cpsm {

class TestAssertionFailure : public std::exception {
 public:
  TestAssertionFailure() : msg_("test assertion failed") {}

  template <typename... Args>
  explicit TestAssertionFailure(Args... args)
      : msg_(str_cat("test assertion failed: ", args...)) {}

  char const* what() const noexcept override { return msg_.c_str(); }

 private:
  std::string msg_;
};

void test_match_order() {
  std::vector<std::string> items({
      "barfoo", "fbar", "foo/bar", "foo/fbar", "foo/foobar", "foo/foo_bar",
      "foo/foo_bar_test", "foo/foo_test_bar", "foo/FooBar", "foo/abar",
      "foo/qux", "foob/ar",
  });

  std::vector<std::string> matches;
  for_each_match<StringRefItem>(
      "fb", Options().set_want_match_info(true),
      range_source<StringRefItem>(items.cbegin(), items.cend()),
      [&](StringRefItem item, MatchInfo const* info) {
        std::printf("Matched %s (%s)\n", item.item().data(),
                    info->score_debug_string().c_str());
        matches.push_back(copy_string_ref(item.item()));
      });

  auto const match_it = [&](boost::string_ref const item) {
    return std::find_if(matches.begin(), matches.end(),
                        [item](boost::string_ref const match)
                            -> bool { return item == match; });
  };
  auto const matched = [&](boost::string_ref const item)
                           -> bool { return match_it(item) != matches.end(); };
  auto const assert_matched = [&](boost::string_ref const item) {
    if (!matched(item)) {
      throw TestAssertionFailure("incorrectly failed to match '", item, "'");
    }
  };
  auto const assert_not_matched = [&](boost::string_ref const item) {
    if (matched(item)) {
      throw TestAssertionFailure("incorrectly matched '", item, "'");
    }
  };
  assert_not_matched("barfoo");
  assert_matched("fbar");
  assert_matched("foo/bar");
  assert_matched("foo/fbar");
  assert_matched("foo/foobar");
  assert_matched("foo/foo_bar");
  assert_matched("foo/foo_bar_test");
  assert_matched("foo/foo_test_bar");
  assert_matched("foo/FooBar");
  assert_matched("foo/abar");
  assert_not_matched("foo/qux");
  assert_matched("foob/ar");

  auto const match_index = [&](boost::string_ref const item) -> std::size_t {
    return match_it(item) - matches.begin();
  };
  auto const assert_match_index =
      [&](boost::string_ref const item, std::size_t expected_index) {
        auto const index = match_index(item);
        if (index != expected_index) {
          throw TestAssertionFailure("expected '", item, "' (index ", index,
                                     ") to have index ", expected_index);
        }
      };
  auto const assert_better_match = [&](boost::string_ref const better_item,
                                       boost::string_ref const worse_item) {
    auto const better_index = match_index(better_item);
    auto const worse_index = match_index(worse_item);
    if (better_index >= worse_index) {
      throw TestAssertionFailure(
          "expected '", better_item, "' (index ", better_index,
          ") to be ranked higher (have a lower index) than '", worse_item,
          "' (index ", worse_index, ")");
    }
  };
  // "fbar" should rank highest due to the query being a full prefix.
  assert_match_index("fbar", 0);
  // "foo/fbar" should rank next highest due to the query being a full prefix,
  // but further away from cur_file (the empty string).
  assert_match_index("foo/fbar", 1);
  // "foo/foo_bar" and "foo/FooBar" should both rank next highest due to being
  // detectable word boundary matches, though it's unspecified which of the two
  // is higher.
  assert_better_match("foo/fbar", "foo/foo_bar");
  assert_better_match("foo/fbar", "foo/FooBar");
  // "foo/foo_bar_test" should rank below either of the above since there are
  // more trailing unmatched characters.
  assert_better_match("foo/foo_bar", "foo/foo_bar_test");
  assert_better_match("foo/FooBar", "foo/foo_bar_test");
  // "foo/foo_bar_test" should rank above "foo/foo_test_bar" since its matched
  // characters are in consecutive words.
  assert_better_match("foo/foo_bar_test", "foo/foo_test_bar");
  // "foo/bar" should rank below all of the above since it breaks the match
  // across multiple path components.
  assert_better_match("foo/foo_test_bar", "foo/bar");
  // "foo/foobar" should rank below all of the above since the 'b' is not a
  // detectable word boundary match.
  assert_better_match("foo/bar", "foo/foobar");
  // "foo/abar" and "foob/ar" should rank lowest since the matched 'b' isn't
  // even at the beginning of the filename in either case, though it's
  // unspecified which of the two is higher.
  assert_better_match("foo/bar", "foo/abar");
  assert_better_match("foo/bar", "foob/ar");
}

}  // namespace cpsm

int main(int argc, char** argv) {
  try {
    cpsm::test_match_order();
    std::printf("PASS\n");
    return 0;
  } catch (std::exception const& ex) {
    std::fprintf(stderr, "FAIL: %s\n", ex.what());
    return 1;
  }
}
