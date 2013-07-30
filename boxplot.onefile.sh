#!/bin/bash

#set -x

usage()
{
cat <<EOF
${txtcyn}
Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to do boxplot using ggplot2.

fileformat for -f (suitable for data extracted from one sample, the
number of columns is unlimited. Column 'Set' is not necessary)

Gene	hmC	expr	Set
NM_001003918_26622	0	83.1269257376101	TP16
NM_001011535_3260	0	0	TP16
NM_001012640_14264	0	0	TP16
NM_001012640_30427	0	0	TP16
NM_001003918_2662217393_30486	0	0	TP16
NM_001017393_30504	0	0	TP16
NM_001025241_30464	0	0	TP16
NM_001017393_30504001025241_30513	0	0	TP16

fileformat when -m is true
#The name "value" and "variable" shoud not be altered.
#"Set" needs to be the parameter after -a.
#Actually this format is the melted result of last format.
value	variable	Set
0	hmC	g
1	expr	g
2	hmC	a
3	expr	a

${txtbld}OPTIONS${txtrst}:
	-f	Data file (with header line, the first column is the
 		colname, tab seperated)${bldred}[NECESSARY]${txtrst}
	-m	When true, it will skip preprocess. But the format must be
		the same as listed before.
		${bldred}[Default FALSE, accept TRUE]${txtrst}
	-a	Name for x-axis variable
		[${txtred}Default variable, which is an inner name, suitable 
		for data without 'Set' column. For the given example, 
		'Set' which represents groups of each gene, and should be 
		supplied to this parameter.
		${txtrst}]
	-l	Levels for legend variable
		[${txtred}Default data order,accept a string like
		"'TP16','TP22','TP23'" for <variable> column.
	   	${txtrst}]
	-P	Legend position[${txtred}Default right. Accept
		top,bottom,left,none, or c(0.08,0.8).${txtrst}]
	-L	Levels for x-axis variable
		[${txtred}Default data order,accept a string like
		"'g','a','j','x','s','c','o','u'" for <Set> column.
	   	${txtrst}]
	-n	Using notch or not.${txtred}[Default TRUE]${txtrst}
	-t	Title of picture[${txtred}Default empty title${txtrst}]
	-x	xlab of picture[${txtred}Default empty xlab${txtrst}]
	-y	ylab of picture[${txtred}Default empty ylab${txtrst}]
	-s	Scale y axis
		[${txtred}Default null. Accept TRUE.
		Also if the supplied number after -S is not 0, this
		parameter is TRUE${txtrst}]
	-v	If scale is TRUE, give the following
		scale_y_log10()[default], coord_trans(y="log10"), 
		scale_y_continuous(trans=log2_trans()), coord_trans(y="log2"), 
	   	or other legal
		command for ggplot2)${txtrst}]
	-o	Exclude outliers.
		[${txtred}Exclude outliers or not, default FALSE means not.${txtrst}]
	-O	The scales for you want to zoom in to exclude outliers.
		[${txtred}Default 1.05. No recommend to change unless you know
		what you are doing.${txtrst}]
	-S	A number to add if scale is used.
		[$(txtred)Default 0. If a non-zero number is given, -s is
		TRUE.${txtrst}]	
	-c	Manually set colors for each line.[${txtred}Default FALSE,
		meaning using ggplot2 default.${txtrst}]
	-C	Color for each line.[${txtred}When -c is TRUE, str in given
		format must be supplied, ususlly the number of colors should
		be equal to the number of lines.
		"'red','pink','blue','cyan','green','yellow'" or
		"rgb(255/255,0/255,0/255),rgb(255/255,0/255,255/255),rgb(0/255,0/255,255/255),
		rgb(0/255,255/255,255/255),rgb(0/255,255/255,0/255),rgb(255/255,255/255,0/255)"
		${txtrst}]
	-p	Other legal R codes for gggplot2 will be given here.
		[${txtres}Begin with '+' ${txtrst}]
	-w	The width of output picture.[${txtred}Default 800${txtrst}]
	-u	The height of output picture.[${txtred}Default 800${txtrst}] 
	-r	The resolution of output picture.[${txtred}Default NA${txtrst}]
	-z	Is there a header[${bldred}Default TRUE${txtrst}]
	-e	Execute or not[${bldred}Default TRUE${txtrst}]
	-i	Install depeneded packages[${bldred}Default FALSE${txtrst}]
EOF
}

file=
title=''
melted='FALSE'
xlab='NULL'
ylab='NULL'
xvariable='variable'
level=""
x_level=""
scaleY='FALSE'
y_add=0
scaleY_x='scale_y_log10()'
header='TRUE'
execute='TRUE'
ist='FALSE'
uwid=800
vhig=800
res='NA'
notch='TRUE'
par=''
outlier='FALSE'
out_scale=1.05
legend_pos='right'

while getopts "hf:m:a:t:x:l:P:L:n:y:o:O:w:u:r:s:S:c:C:p:z:v:e:i:" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		f)
			file=$OPTARG
			;;
		m)
			melted=$OPTARG
			;;
		a)
			xvariable=$OPTARG
			;;
		t)
			title=$OPTARG
			;;
		x)
			xlab=$OPTARG
			;;
		l)
			level=$OPTARG
			;;
		P)
			legend_pos=$OPTARG
			;;
		L)
			x_level=$OPTARG
			;;
		n)
			notch=$OPTARG
			;;
		p)
			par=$OPTARG
			;;
		y)
			ylab=$OPTARG
			;;
		w)
			uwid=$OPTARG
			;;
		u)
			vhig=$OPTARG
			;;
		r)
			res=$OPTARG
			;;
		o)
			outlier=$OPTARG
			;;
		O)
			out_scale=$OPTARG
			;;
		s)
			scaleY=$OPTARG
			;;
		S)
			y_add=$OPTARG
			;;
		c)
			color=$OPTARG
			;;
		C)
			color_v=$OPTARG
			;;
		v)
			scaleY_x=$OPTARG
			;;
		z)
			header=$OPTARG
			;;
		e)
			execute=$OPTARG
			;;
		i)
			ist=$OPTARG
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z $file ]; then
	usage
	exit 1
fi

midname=''

if test "${outlier}" == "TRUE"; then
	midname='.noOutlier'
fi

if test ${y_add} -ne 0; then
	scaleY="TRUE"
fi

if test "${scaleY}" == "TRUE"; then
	midname=${midname}'.scaleY'
fi


cat <<END >${file}${midname}.r

if ($ist){
	install.packages("ggplot2", repo="http://cran.us.r-project.org")
	install.packages("reshape2", repo="http://cran.us.r-project.org")
	install.packages("scales", repo="http://cran.us.r-project.org")
}
library(ggplot2)
library(reshape2)
library(scales)

if(! $melted){

	data <- read.table(file="${file}", sep="\t", header=$header,
	row.names=1)
	if ("$xvariable" != "variable"){
		data_m <- melt(data, id.vars=c("${xvariable}"))
	} else {
		data_m <- melt(data)
	}
} else {
	data_m <- read.table(file="$file", sep="\t",
	header=$header)
}

if (${y_add} != 0){
	data_m\$value <- data_m\$value + ${y_add}
}

if ("${level}" != ""){
	level_i <- c(${level})
	data_m\$variable <- factor(data_m\$variable, levels=level_i)
}
if ("${x_level}" != ""){
	x_level <- c(${x_level})
	data_m\$${xvariable} <- factor(data_m\$${xvariable},levels=x_level)
}

p <- ggplot(data_m, aes(factor($xvariable), value)) + xlab($xlab) +
ylab($ylab)


if (${notch}){
	if (${outlier}){
	p <- p + geom_boxplot(aes(fill=factor(variable)), notch=TRUE,
		notchwidth=0.3, outlier.colour='NA')
	}else{
	p <- p + geom_boxplot(aes(fill=factor(variable)), notch=TRUE,
		notchwidth=0.3)
	}
}else {
	if (${outlier}){
		p <- p + geom_boxplot(aes(fill=factor(variable)),
		outlier.colour='NA')
	}else{
		p <- p + geom_boxplot(aes(fill=factor(variable)))
	}
}

p <- p + theme_bw() + theme(legend.title=element_blank(),
	panel.grid.major = element_blank(), 
	panel.grid.minor = element_blank(),
	legend.key=element_blank())

if("$scaleY"){
	p <- p + $scaleY_x
}

if(${outlier}){
	#ylim_zoomin <- boxplot.stats(data_m\$value)\$stats[c(1,5)]
	stats <- boxplot.stats(data_m\$value)\$stats
	ylim_zoomin <- c(stats[1]/${out_scale}, stats[5]*${out_scale})
	p <- p + coord_cartesian(ylim = ylim_zoomin)
}


top='top'
botttom='bottom'
left='left'
right='right'
none='none'
legend_pos_par <- ${legend_pos}

#if ("${legend_pos}" != "right"){
p <- p + theme(legend.position=legend_pos_par)
#}

if($color){
	p <- p + scale_fill_manual(values=c(${color_v}))
}

p <- p${par}

png(filename="${file}${midname}.png", width=$uwid, height=$vhig,
res=$res)
p
dev.off()
END

if [ "$execute" == "TRUE" ]; then
	Rscript ${file}${midname}.r
fi

