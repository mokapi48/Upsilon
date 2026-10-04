# Define standard compilation rules

$(eval $(call rule_for, \
  AS, %.o, %.s, \
  $$(CC) $$(SFLAGS) -c $$< -o $$@, \
  global local \
))

$(eval $(call rule_for, \
  CC, %.o, %.c, \
  $$(CC) $$(CFLAGS) $$(SFLAGS) -c $$< -o $$@, \
  global local \
))

$(eval $(call rule_for, \
  CPP, %, %.inc, \
  $$(CPP) $$(addprefix -I,$$(dir $$^)) -P $$< $$@, \
  global \
))

$(eval $(call rule_for, \
  CXX, %.o, %.cpp, \
  $$(CXX) $$(CXXFLAGS) $$(SFLAGS) -c $$< -o $$@, \
  global local \
))

$(eval $(call rule_for, \
  DFUSE, %.dfu, %.elf, \
  $$(PYTHON) build/device/elf2dfu.py $$< $$@, \
  local \
))

$(eval $(call rule_for, \
  OBJCOPY, %.hex, %.elf, \
  $$(OBJCOPY) -R .slot_info -O ihex $$< $$@, \
  local \
))

$(eval $(call rule_for, \
  OBJCOPY, %.bin, %.elf, \
  $$(OBJCOPY) -R .slot_info -O binary $$< $$@, \
  local \
))

$(eval $(call rule_for, \
  OCC, %.o, %.m, \
  $$(CC) $$(CFLAGS) $$(SFLAGS) -c $$< -o $$@, \
  global \
))

$(eval $(call rule_for, \
  OCC, %.o, %.mm, \
  $$(CXX) $$(CXXFLAGS) $$(SFLAGS) -c $$< -o $$@, \
  global \
))

$(eval $(call rule_for, \
  WINDRES, %.o, %.rc, \
  $$(WINDRES) $$(WRFLAGS) $$< -O coff -o $$@, \
  global \
))

$(eval $(call rule_for, \
  ZIP, %.zip, , \
  rm -rf $$(basename $$@) && mkdir -p $$(basename $$@) && cp $$^ $$(basename $$@) && zip -r -9 -j $$@ $$(basename $$@) > /dev/null && rm -rf $$(basename $$@), \
  global \
))

ifdef EXE
ifeq ($(OS),Windows_NT)
# Work around command-line length limit
# On Msys2 the max command line is 32 000 characters. Our standard LD command
# can be longer than that because we have quite a lot of object files. To work
# around this issue, we write the object list in a "target.objs" file, and tell
# the linker to read its arguments from this file.
# NOTE: the list is written with GNU make's file function instead of an `echo`,
# because the sh -c command line itself exceeds the 32 767-character
# CreateProcess limit with ~1500 object files (make e=206 on native Windows).
$(eval $(call rule_for, \
  LD, %.$$(EXE), , \
  $$(file >$$@.objs,$$^)$$(LD) @$$@.objs $$(LDFLAGS) -o $$@ && rm $$@.objs, \
  global \
))
else
$(eval $(call rule_for, \
  LD, %.$$(EXE), , \
  $$(LD) $$^ $$(LDFLAGS) -o $$@, \
  global \
))
endif
endif
