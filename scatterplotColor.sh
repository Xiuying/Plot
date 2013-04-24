#!/bin/bash

#set -x

usage()
{
cat <<EOF
${txtcyn}
Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to do scatter plot and color them by the third
column data using ggplot2. 
It is designed for representing the expression data which
may be affected by multiple factors(here for two). 

The parameters for logical variable are either TRUE or FALSE.

${txtbld}OPTIONS${txtrst}:
	-f	Data file (with header line, the first column is the
 		colname, tab seperated)${bldred}[NECESSARY]${txtrst}
	-t	Title of picture[${txtred}Default empty title${txtrst}]
		[Scatter plot of horizontal and vertical variable]
	-x	xlab of picture[${txtred}Default empty xlab${txtrst}]
		[The description for horizontal variable]
	-y	ylab of picture[${txtred}Default empty ylab${txtrst}]
		[The description for vertical variable]
	-l	The legend for color scale.[${txtred}Default the 
		variable for color value${txtrst}]
	-o	The variable for horizontal axis.${bldred}[NECESSARY]${txtrst}
	-v	The variable for vertical axis.${bldred}[NECESSARY]${txtrst}
	-c	The variable for color value.${bldred}[NECESSARY]${txtrst}
	-g	Log transfer[${bldred}Default none, accept log, log2${txtrst}].
	-w	The width of pictures.[${bldred}Default system default${txtrst}]
	-a	The height of pictures.[${bldred}Default system default${txtrst}]
	-r	The resolution of pictures.[${bldred}Default system default${txtrst}] 
	-b	The formula for facets.[${bldred}Default no facets, 
		facet_grid(level ~ .) means divide by levels of 'level' vertcally.
		facet_grid(. ~ level) means divide by levels of 'level' horizontally.
		facet_grid(lev1 ~ lev2) means divide by lev1 vertically and lev2
		horizontally.
		facet_wrap(~level, ncol=2) means wrap horizontally with 2
		columns.
		${txtrst}]
	-d	If facet is given, you may want to specifize the order of
		variable in your facet, default alphabetically.
		[${txtred}Accept sth like 
		(one level one sentence, separate by';') 
		data\$level <- factor(data\$level, levels=c("l1",
		"l2",...,"l10"), ordered=T) ${txtrst}]
	-s	smoothed fit curve with confidence region or not.
		[${bldred}Default loss smooth, one can give 'lm' to
		get linear smooth. FALSE for no smooth.${txtrst}]
	-z	Other parameters in ggplot format.[${bldred}selection${txtrst}]
	-e	Execute or not[${bldred}Default TRUE${txtrst}]
	-i	Install the required packages[${bldred}Default FALSE${txtrst}]
EOF
}

file=''
title=''
xlab=''
ylab=''
xval=''
yval=''
execute='TRUE'
ist='FALSE'
color=''
col_legend=''
log=''
width=''
height=''
res=''
facet=''
smooth='geom_smooth'
other=''
facet_o=''

while getopts "hf:t:x:y:o:v:c:l:g:w:a:r:s:b:d:z:e:i:" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		f)
			file=$OPTARG
			;;
		t)
			title=$OPTARG
			;;
		x)
			xlab=$OPTARG
			;;
		y)
			ylab=$OPTARG
			;;
		o)
			xval=$OPTARG
			;;
		v)
			yval=$OPTARG
			;;
		c)
			color=$OPTARG
			;;
		l)
			col_legend=$OPTARG
			;;
		g)
			log=$OPTARG
			;;
		w)
			width=$OPTARG
			;;
		a)
			height=$OPTARG
			;;
		r)
			res=$OPTARG
			;;
		b)
			facet=$OPTARG
			;;
		d)
			facet_o=$OPTARG
			;;
		s)
			smooth=$OPTARG
			;;
		z)
			other=$OPTARG
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

midname=".scatterplot.color"
if [ -z $file ] || [ -z $xval ] || [ -z $yval ] || [ -z $color ]; then
	echo 1>&2 "Please give filename, xval and yval."
	usage
	exit 1
fi


if [ -z $col_legend ]; then
	col_legend="$color"
fi

if [ ! -z $log ]; then
	log=", trans=\"${log}\""
fi

cat <<END >${file}${midname}.r

if ($ist){
	install.packages("ggplot2", repo="http://cran.us.r-project.org")
}
library(ggplot2)
data <- read.table(file="$file", sep="\t", header=T, row.names=1)

if ("$width" != "" && "$height" != ""  && "$res" != ""){
	png(filename="${file}${midname}.png", width=$width, height=$height,
	res=$res)
}else{
	png(filename="${file}${midname}.png")
}

$facet_o

p <- ggplot(data, aes(x=${xval},y=${yval})) \
+ geom_point(aes(color=${color})) \
+ scale_colour_gradient(low="green", high="red", 
name="$col_legend" ${log}) \
+ labs(x="$xlab", y="$ylab") + opts(title="$title")

if ("$facet" != ""){
	facet=$facet
	p <- p + facet
}

if ("$smooth" == "geom_smooth"){
	p <- p + geom_smooth()
} else 
if ("$smooth" == 'lm'){
	p <- p + geom_smooth(method=lm)
}

if ("$other" != ''){
	other=$other
	p <- p + other
}


p <- p + theme_bw() + theme(legend.title=element_blank(),
panel.grid.major = element_blank(), panel.grid.minor = element_blank())

p
dev.off()
#+ geom_point(alpha=1/10)
END

if [ "$execute" == "TRUE" ]; then
	Rscript ${file}${midname}.r
fi

if [ ! -z "$log" ]; then
	log=', trans=\"'$log'\"'
fi

#convert -density 200 -flatten ${file}${midname}.eps ${first}${midname}.png
