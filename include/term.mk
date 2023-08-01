
philmk_term_COLOR_BLACK   := 0
philmk_term_COLOR_RED     := 1
philmk_term_COLOR_GREEN   := 2
philmk_term_COLOR_YELLOW  := 3
philmk_term_COLOR_BLUE    := 4
philmk_term_COLOR_MAGENTA := 5
philmk_term_COLOR_CYAN    := 6
philmk_term_COLOR_WHITE   := 7

##
# Set foreground color.
#
philmk_term_set_a_foreground = $(call philmk_tput,setaf $(1))

philmk_term_fg_red := $(call philmk_term_set_a_foreground,$(philmk_term_COLOR_RED))
philmk_term_exit_attribute_mode := $(call philmk_tput,sgr0)
