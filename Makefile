MMC ?= mmc

all: plp_demo ctl_demo tabling_demo naf_demo dtmc_demo mm_demo mmb_demo mm_multi_demo semiotic_demo grounding_demo social_mm_demo control_filter_demo film_episode_demo film_episode_test film_annotation_fixture_test meshes_gold_scene_demo meshes_gold_scene_test

plp_demo: plp.m semiring.m plp_demo.m
	$(MMC) --make plp_demo

ctl_demo: ctl.m ctl_demo.m
	$(MMC) --make ctl_demo

tabling_demo: tabling.m tabling_demo.m
	$(MMC) --make tabling_demo

naf_demo: plp.m plp_naf.m naf_demo.m
	$(MMC) --make naf_demo

dtmc_demo: dtmc.m ctl.m dtmc_demo.m
	$(MMC) --make dtmc_demo

mm_demo: mm.m mm_demo.m
	$(MMC) --make mm_demo

mmb_demo: mmb.m mm.m mmb_demo.m
	$(MMC) --make mmb_demo

mm_multi_demo: mm.m mm_multi.m mm_multi_demo.m
	$(MMC) --make mm_multi_demo

semiotic_demo: mm.m mm_multi.m semiotic_demo.m
	$(MMC) --make semiotic_demo

grounding_demo: mm.m mmb.m ec.m grounding_demo.m
	$(MMC) --make grounding_demo

social_mm_demo: social_mm.m social_mm_demo.m
	$(MMC) --make social_mm_demo

control_filter_demo: control_filter.m control_filter_demo.m
	$(MMC) --make control_filter_demo

film_episode_demo: film_episode.m film_episode_demo.m
	$(MMC) --make film_episode_demo

film_episode_test: film_episode.m film_episode_test.m
	$(MMC) --make film_episode_test

film_annotation_fixture_test: film_episode.m film_annotation_fixture.m film_annotation_fixture_test.m
	$(MMC) --make film_annotation_fixture_test

meshes_gold_scene_demo: film_episode.m meshes_gold_scene_fixture.m meshes_gold_scene_demo.m
	$(MMC) --make meshes_gold_scene_demo

meshes_gold_scene_test: film_episode.m meshes_gold_scene_fixture.m meshes_gold_scene_test.m
	$(MMC) --make meshes_gold_scene_test

run: all
	./plp_demo
	./ctl_demo
	./tabling_demo
	./naf_demo
	./dtmc_demo
	./mm_demo
	./mmb_demo
	./mm_multi_demo
	./semiotic_demo
	./grounding_demo
	./social_mm_demo
	./control_filter_demo
	./film_episode_demo
	./film_episode_test
	./film_annotation_fixture_test
	./meshes_gold_scene_demo
	./meshes_gold_scene_test

clean:
	rm -rf Mercury *.c *.o *.err *.mh *.mih
	rm -f plp_demo ctl_demo tabling_demo naf_demo dtmc_demo mm_demo mmb_demo mm_multi_demo semiotic_demo grounding_demo social_mm_demo control_filter_demo film_episode_demo film_episode_test film_annotation_fixture_test meshes_gold_scene_demo meshes_gold_scene_test

.PHONY: all run clean
