from torchbenchmark import load_model_by_name

models = [
    "vgg16",
    "alexnet",
    "resnet18",
    "resnet50",
    "resnet152",
    "mnasnet1_0",
    "densenet121",
    "mobilenet_v2",
    "squeezenet1_1",
    "resnext50_32x4d",
    "mobilenet_v3_large",
    "shufflenet_v2_x1_0",
]

for model in models:
    print(f"Getting weights for {model}")
    Model = load_model_by_name(model)
    Model(device="cpu", test="eval", jit=False)

