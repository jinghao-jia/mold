#!/bin/bash
. $(dirname $0)/common.inc

# OneTBB isn't tsan-clean
nm mold | grep '__tsan_init' && skip

cat <<EOF | $CC -c -o $t/a.o -xc -
void bar();
void foo() {
  bar();
}
EOF

cat <<EOF | $CC -c -o $t/b.o -xc -
void bar() {}
EOF

cat <<EOF | $CC -c -o $t/c.o -xc -
void baz() {}
EOF

cat <<EOF | $CC -c -o $t/d.o -xc -
void foo();
int main() {
  foo();
}
EOF

ar crs $t/e.a $t/a.o $t/b.o $t/c.o
./mold -r -o $t/f.o $t/d.o $t/e.a

readelf --symbols $t/f.o > $t/log
grep 'foo\b' $t/log
grep 'bar\b' $t/log
not grep 'baz\b' $t/log
