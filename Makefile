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
	IpolPlugins \
	ScwalPlugins \
	computation-lab	
	
BRANCHES = \
	EcosystemScience,master \
	Soja,master \
	Soda,master \
	Celo,master \
	Sipe,master \
	PrepArg,master \
	ScwalPlugins,master \
	computation-lab \
	scills,master

	
	
SYM_LINKS = \
	EcosystemScience,Javascript \
	computation-lab,Ruby \
	ScwalPlugins,ScwalPlugins \
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

LD = \
	libfftw3-dev \
	libjpeg-dev \
	libpng12-dev \
	libtiff4-dev \
	scons \
	gcc \
	g++ \
	python \
	python-dev \
	libpython-devel \
	python-all-dev \
	swig \
	libboost-dev \
	libgsl0-dev \
	libxml2-dev \
	libxml++2 \
	libreadline-dev \
	cmake \
	libqt4-core \
	libqt4-dev \
	qt4-qmake \
	libhdf5-serial-dev \
	qtcreator \
	coffeescript \
	openmpi-bin \
	libopenmpi-dev \
	zlib1g-dev \
	libglew-dev \
	libxi-dev \
	libxmu-dev \
	freeglut3-dev \
	libcurl4-openssl-dev
	
	
	
SHELL = /bin/bash


all: compilation
	which easy_install || sudo apt-get install python-setuptools
	python -c "import pyev" || sudo easy_install pyev
	python -c "import ramona" || sudo easy_install ramona
	# ==========================================================
	# Lancement de ramona -> http://localhost:5588
	# ==========================================================
	./ram.py server

basic:
	make -C Javascript mechanic

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
	make -C software_library/ScwalPlugins/GlobalManagerPlugin
	
plugins_with_sleep: compilation
	sleep 5
	make plugins


software_library:
	mkdir software_library
	
prereq: software_library
	# ========================= CLONING IF NECESSARY =========================
	for i in ${LIBRARIES}; do test -e software_library/$$i || git clone git@github.com:structure-computation/$$i software_library/$$i; done

pull:
	for i in ${LIBRARIES}; do \
		pushd software_library/$$i; \
		git pull; \
		popd; \
	done

push:
	for i in ${LIBRARIES}; do \
		pushd software_library/$$i; \
		git commit -a; \
		git push; \
		popd; \
	done

branches: prereq
	# ========================= SETTING BRANCHES =========================
	for i in ${BRANCHES}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		B=`echo $$i | sed 's/.*,\\(.*\\)/\\1/'`; \
		pushd software_library/$$R; \
		git checkout -b $$B origin/$$B 2> /dev/null || git checkout $$B; \
		popd; \
	done

ld_libraries: prereq
	# ========================= LD LIBRARIES =========================
	for i in ${LD}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		( dpkg --status $$R > /dev/null ) || sudo apt-get install $$R; \
	done
	
sym_links: ld_libraries
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
