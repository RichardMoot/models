# French Part-of-Speech tag and Supertag models

This repository contains the model directories for French Part-of-Speech (POS) and supertags, obtained from the [TLGbank](https://github.com/RichardMoot/TLGbank/) for use with the
[C&C supertagger
  and part-of-speech tagger](http://svn.ask.it.usyd.edu.au/trac/candc/wiki).

### Performance overview of the different models

Performance overview for commit [a2a143c4a30d699f878f9c7c4f55635672a2f537](https://github.com/RichardMoot/models/commit/a2a143c4a30d699f878f9c7c4f55635672a2f537).

##### Supertag models with gold POS tags

Model | Correct (beta=1) | F/w |Correct (beta=0.1) | F/w | Correct (beta=0.05) | F/w | Correct (beta=0.01) | F/w | Correct (beta=0.005)| F/w | Correct (beta=0.001) | F/w
------|---------:|-----------:|-------:|----------:|--------:|----------:|--------:|----------:|--------:|----------:|--------:|---------:
Merged | 90.41 |  1.0 | 96.31 |  1.4 | 97.17 |  1.6 | 98.37 |  2.3 | 98.54 |  2.8 | 98.80 |  4.5
Melt | 90.36 |  1.0 | 96.42 |  1.4 | 97.25 |  1.6 | 98.43 |  2.4 | 98.62 |  2.9 | 98.88 |  4.5
Tt |  90.12 |  1.0 | 96.25 |  1.4 | 97.16 |  1.6 | 98.39 |  2.4 | 98.56 |  2.9 | 98.84 |  4.6
Simple | 90.15 |  1.0 | 96.30 |  1.4 | 97.19 |  1.6 | 98.43 |  2.4 | 98.62 |  2.9 | 98.87 |  4.6


##### Combined POS- and supertagger

Model | Correct (beta=1) | F/w |Correct (beta=0.1) | F/w | Correct (beta=0.05) | F/w | Correct (beta=0.01) | F/w | Correct (beta=0.005)| F/w | Correct (beta=0.001) | F/w
------|---------:|-----------:|-------:|----------:|--------:|----------:|--------:|----------:|--------:|----------:|--------:|---------:
Merged | 88.71 |  1.0 | 94.77 |  1.4 | 95.68 |  1.6 | 97.23 |  2.4 | 97.55 |  2.9 | 98.06 |  4.5
Melt | 88.78 |  1.0 | 94.83 |  1.4 | 95.73 |  1.6 | 97.22 |  2.4 | 97.55 |  2.9 | 98.10 |  4.5
Tt  | 88.79 |  1.0 | 95.05 |  1.4 | 96.05 |  1.6 | 97.55 |  2.4 | 97.81 |  2.9 | 98.26 |  4.6
Simple | 88.86 |  1.0 | 95.12 |  1.4 | 96.10 |  1.6 | 97.57 |  2.4 | 97.86 |  2.9 | 98.29 |  4.6

##### Direct


Model | Correct (beta=1) | F/w |Correct (beta=0.1) | F/w | Correct (beta=0.05) | F/w | Correct (beta=0.01) | F/w | Correct (beta=0.005)| F/w | Correct (beta=0.001) | F/w
------|---------:|-----------:|-------:|----------:|--------:|----------:|--------:|----------:|--------:|----------:|--------:|---------:
Direct | 86.87 |  1.0 | 94.81 |  1.5 | 95.91 |  1.8 | 97.30 |  2.9 | 97.57 |  3.7 | 97.94 |  6.3


##### POS models

Model | Correct |
-----|-----:|
Merged  | 97.99
Melt  | 98.25
Tt    | 98.41
Simple  | 98.49
