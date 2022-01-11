#!/bin/bash
ipset -F BLACKLIST_SrcDstportDst
ipset -F botnets
ipset -F bad_client
ipset -F unreliable_client