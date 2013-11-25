LIBRARIES = \
	scult \
	scills \
	metis-4 \
	LMTpp \
	dic \
	METIL-lang \
	Metil \
	Soca \
	Soda \
	Soja \
	Celo \
	Sipe \
	PrepArg \
	EcosystemScience \
	ScwalPlugins \
	computation-lab	
	
BRANCHES = \
	Soja,WebGl_inline
	
# 	EcosystemScience,modif_design \
	
SYM_LINKS = \
	EcosystemScience,Javascript \
	computation-lab,Ruby \
	ScwalPlugins,Plugins \
	Soja,software_library/EcosystemScience/ext/Soja \
	Soda,software_library/EcosystemScience/ext/Soda \
	Celo,software_library/Soda/ext/Celo \
	Sipe,software_library/Soda/ext/Sipe \
	PrepArg,software_library/Soda/ext/PrepArg \
	scult/src/GEOMETRY,software_library/scills/src/GEOMETRY \
	scult/src/COMPUTE,software_library/scills/src/COMPUTE \
	scult/src/UTILS,software_library/scills/src/UTILS \
	scills/src,software_library/ScwalPlugins/Scills3DPlugin/ServerPlugin/src_scills \
	LMTpp,software_library/scult/LMT \
	LMTpp,software_library/scills/LMT \
	LMTpp,software_library/ScwalPlugins/GmshPlugin/ServerPlugin/LMT \
	LMTpp,software_library/ScwalPlugins/Scills3DPlugin/ServerPlugin/LMT \
	LMTpp,software_library/ScwalPlugins/Scult3DPlugin/ServerPlugin/LMT \
	LMTpp,software_library/ScwalPlugins/CorreliPlugin/ServerPlugin/LMT \
	LMTpp,software_library/ScwalPlugins/GlobalManagerPlugin/ServerPlugin/LMT \
	dic,software_library/ScwalPlugins/CorreliPlugin/ServerPlugin/dic

	
	
SHELL = /bin/bash
	
all: compilation
	which easy_install || sudo apt-get install easy_install
	python -c "import ramona" || sudo easy_install ramona
	# ==========================================================
	# Lancement de ramona -> http://localhost:5588
	# ==========================================================
	./ram.py server

compilation: sym_links
	which metil_comp || make -C software_library/Metil install
	make -C software_library/ScwalPlugins/GmshPlugin
	# 	make -C software_library/ScwalPlugins/Scills3DPlugin
	# 	make -C software_library/ScwalPlugins/Scult3DPlugin
	make -C software_library/ScwalPlugins/CorreliPlugin
	make -C software_library/EcosystemScience Soja_javascripts
	
	
soda_server: compilation
	make -C Javascript mechanic

plugins: compilation
	make -C Plugins/GlobalManagerPlugin
	
plugins_with_sleep: compilation
	sleep 10
	make plugins


software_library:
	mkdir software_library
	
prereq: software_library
	# ========================= CLONING IF NECESSARY =========================
	for i in ${LIBRARIES}; do test -e software_library/$$i || git clone git@github.com:structure-computation/$$i software_library/$$i; done

branches: prereq
	# ========================= SETTING BRANCHES =========================
	for i in ${BRANCHES}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		B=`echo $$i | sed 's/.*,\\(.*\\)/\\1/'`; \
		pushd software_library/$$R; \
		git checkout -b $$B origin/$$B 2> /dev/null || git checkout $$B; \
		popd; \
	done
	
sym_links: prereq
	# ========================= SYMBOLIC LINKS =========================
	for i in ${SYM_LINKS}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		B=`echo $$i | sed 's/.*,\\(.*\\)/\\1/'`; \
		mkdir -p `dirname $$B`; \
		test -e $$B || ln -s `pwd`/software_library/$$R $$B; \
	done

#  		test -e $$B && ( test -h $$B || ( echo $$B SHOULD BE A SYMLINK -- GOING TO DELETE IT; read ) ) ; \
# 		rm $$B; \

# 
# Dans scills
# ln -s ../scult/src/GEOMETRY src/GEOMETRY 
# ln -s ../scult/src/COMPUTE src/COMPUTE 
# ln -s ../scult/src/UTILS src/UTILS
# mkdir UTIL
# cd UTIL ; ln -s ../../metis-4 metis ; ln -s /usr/include/openmpi openmpi


.PHONY: prereq branches sym_links server compilation
