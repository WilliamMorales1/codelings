#!/usr/bin/env bash
# REQUIRES: ip unshare
# HINT
# For each destination list every route that contains it, then take the most
# specific one. 10.8.5.7 is inside 10.8.0.0/16, 10.8.4.0/22 (10.8.4.0-10.8.7.255)
# and 10.8.5.0/24; the /24 wins. 10.8.200.1 is only inside the /16.
# Anything that matches nothing more specific takes the default route.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
ip link add wlan0 type dummy && ip link set wlan0 up && ip addr add 192.168.1.23/24 dev wlan0
ip link add wg0 type dummy && ip link set wg0 up && ip addr add 10.8.0.5/24 dev wg0
sandbox_here "wlan0 and wg0 exist here as dummy interfaces. Add the routes from routes.txt, then 'ip route get ADDR'."

expect_answer dest_1_1_1_1 c5eb5a4cc76a5cdb16e79864b9ccd26c3553f0c396d0a21bafb7be71c1efcd8c "nothing specific matches"
expect_answer dest_10_8_0_77 d15690f08a575024650b01ffac892cfd2b93e6c57c140f1b6d9e47753cabd579 "on wg0's own /24"
expect_answer dest_10_8_5_7 c987e762b74a83036cddd777a780c0cb887bc05109894287262d3f9ae752585d "the /24 beats the /22 and the /16"
expect_answer dest_10_8_6_1 6630f1d0895e1a2993319d962c0bacbf2763853bcdc6beb32e7632428221b52c "inside the /22"
expect_answer dest_10_8_200_1 6630f1d0895e1a2993319d962c0bacbf2763853bcdc6beb32e7632428221b52c "only the /16 matches"
expect_answer dest_10_99_3_4 e7edd6da7bc67389f20bdf84c95fd5c852b1585f648f209822a012f2cd9daf5a "blackhole route"
expect_answer dest_192_168_1_50 d15690f08a575024650b01ffac892cfd2b93e6c57c140f1b6d9e47753cabd579 "on wlan0's own subnet"
expect_answer dev_10_8_5_7 f2fb6f663fba09e4161bf54e107f44ba81e09c69857ed4fa3246cd3f91cd91dc "the /24 route leaves via wlan0"
