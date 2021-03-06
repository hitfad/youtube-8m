GPU_ID=1
EVERY=500
MODEL=LstmMemoryNormalizationModel
MODEL_DIR="../model/lstmmemory1024_moe8_l2norm"

start=$1
DIR="$(pwd)"

for checkpoint in $(cd $MODEL_DIR && python ${DIR}/training_utils/select.py $EVERY); do
	echo $checkpoint;
	if [ $checkpoint -gt $start ]; then
		echo $checkpoint;
		CUDA_VISIBLE_DEVICES=$GPU_ID python eval.py \
			--train_dir="$MODEL_DIR" \
			--model_checkpoint_path="${MODEL_DIR}/model.ckpt-${checkpoint}" \
			--eval_data_pattern="/Youtube-8M-validate/validatea*" \
			--frame_features=True \
			--feature_names="rgb,audio" \
			--feature_sizes="1024,128" \
			--batch_size=128 \
			--model=$MODEL \
			--lstm_normalization="l2_normalize" \
			--feature_transformer="IdenticalTransformer" \
			--lstm_cells=1024 \
			--lstm_layers=2 \
			--moe_num_mixtures=8 \
			--num_readers=1 \
			--rnn_swap_memory=True \
			--run_once=True
	fi
done

