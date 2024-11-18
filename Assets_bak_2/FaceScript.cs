using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceScript : MonoBehaviour
{
    private Transform headTransform;
    private Transform headForward;
    private Transform headRight;
    private Material[] faceMaterials;
    // Start is called before the first frame update
    void Start()
    {
        headTransform = transform.Find("Armature/Hips/Spine/Chest/Upper_Chest/Neck/Head").GetComponent<Transform>();
        headForward = transform.Find("Armature/Hips/Spine/Chest/Upper_Chest/Neck/Head/HeadForward").GetComponent<Transform>();
        headRight = transform.Find("Armature/Hips/Spine/Chest/Upper_Chest/Neck/Head/HeadRight").GetComponent<Transform>();

        SkinnedMeshRenderer render = transform.Find("Body").GetComponent<SkinnedMeshRenderer>();
        Material[] allMaterials = render.materials;

        faceMaterials = new Material[3];
        faceMaterials[0] = allMaterials[0];
        faceMaterials[1] = allMaterials[1];
        faceMaterials[2] = allMaterials[2];
        //       faceMaterials[3] = allMaterials[3];
        //        faceMaterials[4] = allMaterials[4];
        //        faceMaterials[5] = allMaterials[5];
        //faceMaterials[6] = allMaterials[6];
        //faceMaterials[7] = allMaterials[7];
        //faceMaterials[8] = allMaterials[16];

        Update();
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 forwardVector = headForward.position - headTransform.position;
        Vector3 rightVector = headRight.position - headTransform.position;

        forwardVector = forwardVector.normalized;
        rightVector = rightVector.normalized;

        Vector4 forwardVector4 = new Vector4(forwardVector.x, forwardVector.y, forwardVector.z);
        Vector4 rightVector4 = new Vector4(rightVector.x, rightVector.y, rightVector.z);

        for (int i = 0; i < faceMaterials.Length; i++)
        {
            Material material = faceMaterials[i];
            material.SetVector("_ForwardVector", forwardVector4);
            material.SetVector("_RightVector", rightVector4);
        }

        print(forwardVector4);
        print(rightVector4);
        print("\n");
    }
}
