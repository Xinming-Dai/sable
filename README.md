# SABLE

**S**parse-view **A**nimal **B**ehavior **L**atent **E**mbeddings

[![arXiv](https://img.shields.io/badge/arXiv-2609.36217-b31b1b?logo=arxiv&logoColor=white)](https://arxiv.org/abs/2609.36217)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

SABLE is a self-supervised framework for learning interpretable 3D representations of animal
behavior from sparse multi-view video. It combines a multi-view transformer with monocular-depth
and pose priors to reconstruct 3D behavior from as few as two views, without ground-truth 3D
labels. The learned representations support neural encoding and decoding and generalize to unseen
animals without animal-specific calibration or retraining.

For details, see the [paper](https://arxiv.org/abs/2609.36217).

## Installation

SABLE requires Python 3.10--3.12, a CUDA-capable GPU for training, and `ffmpeg` for video
preprocessing.

```bash
conda create --yes --name sable python=3.11
conda activate sable
pip install lightning poetry-core
pip install -e . --no-build-isolation
```

Run `beast --help` to confirm the installation.

## Quick start

1. Set the dataset paths and model checkpoints in one of the provided configs:
   [`configs/sable/sable_ibl3d.yaml`](configs/sable/sable_ibl3d.yaml) or
   [`configs/sable/sable_cheese3d.yaml`](configs/sable/sable_cheese3d.yaml).
2. For IBL stereo video, prepare frames, monocular-depth priors, and optional pose
   correspondences:

   ```bash
   beast extract_sable --config configs/multiview/extraction_pipeline_sable.yaml
   ```

3. Train SABLE:

   ```bash
   beast train --config configs/sable/sable_ibl3d.yaml
   ```

Dataset-specific instructions are available for [IBL data preparation](docs/sable/extract_data_for_sable.md),
[Cheese3D training](docs/sable/cheese3d_dataset.md), and
[neural encoding and decoding](docs/sable/neural_encoding_decoding.md).

## Acknowledgements

This repository is built upon the [BEAST repository](https://github.com/paninski-lab/beast/tree/main).

## Citation

If you use SABLE, please cite:

```bibtex
@article{dai2026sable,
  title   = {Sparse-View Interpretable 3D Animal Behavior Representations for Neural Encoding and Decoding},
  author  = {Dai, Xinming and Jin, Qihang and Zhang, Jiaying and Tan, Tianshu and Chen, Baiyuan and
             Lyu, Hanrui and Aharon, Lenny and Daruwalla, Kyle and Hou, Xun Helen and
             Whiteway, Matthew R. and Paninski, Liam and Zhang, Yizi},
  journal = {arXiv preprint arXiv:2609.36217},
  year    = {2026}
}
```

## License

This project is released under the [MIT License](LICENSE).
