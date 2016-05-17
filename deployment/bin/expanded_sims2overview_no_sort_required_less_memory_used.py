#!/bin/sh
export KB_TOP=/kb/deployment
export KB_RUNTIME=/kb/runtime
export PATH=/kb/runtime/bin:/kb/deployment/bin:$PATH
export PERL5LIB=/kb/deployment/lib
/kb/runtime/bin/perl /kb/deployment/plbin/expanded_sims2overview_no_sort_required_less_memory_used.py "$@"
